// AdmitCraft Backend API Server
// This server acts as a secure proxy for Anthropic API calls

const express = require('express');
const cors = require('cors');
const Anthropic = require('@anthropic-ai/sdk');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize Anthropic client
const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Rate limiting (simple in-memory implementation)
const rateLimitMap = new Map();
const RATE_LIMIT = 20; // requests per hour
const RATE_LIMIT_WINDOW = 60 * 60 * 1000; // 1 hour in ms

function checkRateLimit(ip) {
  const now = Date.now();
  const userRequests = rateLimitMap.get(ip) || [];
  
  // Remove old requests outside the window
  const recentRequests = userRequests.filter(time => now - time < RATE_LIMIT_WINDOW);
  
  if (recentRequests.length >= RATE_LIMIT) {
    return false;
  }
  
  recentRequests.push(now);
  rateLimitMap.set(ip, recentRequests);
  return true;
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'AdmitCraft API' });
});

// Main API endpoint for essay generation/editing
app.post('/api/generate', async (req, res) => {
  const ip = req.ip || req.connection.remoteAddress;
  
  // Check rate limit
  if (!checkRateLimit(ip)) {
    return res.status(429).json({
      error: 'Rate limit exceeded',
      message: 'Too many requests. Please try again later.',
      retryAfter: 3600
    });
  }

  try {
    const { messages, maxTokens = 4000 } = req.body;

    // Validate request
    if (!messages || !Array.isArray(messages) || messages.length === 0) {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'Messages array is required'
      });
    }

    // Validate message length (prevent abuse)
    const totalLength = messages.reduce((sum, msg) => 
      sum + (msg.content?.length || 0), 0
    );
    
    if (totalLength > 50000) {
      return res.status(400).json({
        error: 'Content too long',
        message: 'Total message content exceeds maximum length'
      });
    }

    // Call Anthropic API
    const response = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: maxTokens,
      messages: messages
    });

    // Return response
    res.json({
      content: response.content,
      usage: response.usage
    });

  } catch (error) {
    console.error('Anthropic API Error:', error);
    
    if (error.status === 429) {
      return res.status(429).json({
        error: 'API rate limit',
        message: 'Service is experiencing high demand. Please try again in a few moments.'
      });
    }
    
    if (error.status === 400) {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'The request could not be processed. Please check your input.'
      });
    }
    
    res.status(500).json({
      error: 'Server error',
      message: 'An unexpected error occurred. Please try again.'
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`AdmitCraft API Server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});

module.exports = app;
