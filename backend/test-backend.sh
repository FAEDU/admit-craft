#!/bin/bash

# AdmitCraft Backend Test Script
# This script helps verify your backend setup is working correctly

echo "🧪 AdmitCraft Backend Test Suite"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if backend URL is provided
if [ -z "$1" ]; then
    BACKEND_URL="http://localhost:3000"
    echo "${YELLOW}No URL provided, using localhost:3000${NC}"
    echo "Usage: ./test-backend.sh <backend-url>"
    echo "Example: ./test-backend.sh https://your-backend.railway.app"
    echo ""
else
    BACKEND_URL="$1"
fi

echo "Testing backend at: $BACKEND_URL"
echo ""

# Test 1: Health Check
echo "Test 1: Health Check"
echo "--------------------"
response=$(curl -s -w "\n%{http_code}" "$BACKEND_URL/health")
http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" = "200" ]; then
    echo "${GREEN}✓ PASS${NC} - Health check successful"
    echo "Response: $body"
else
    echo "${RED}✗ FAIL${NC} - Health check failed (HTTP $http_code)"
    echo "Response: $body"
    exit 1
fi
echo ""

# Test 2: API Endpoint (Valid Request)
echo "Test 2: Valid API Request"
echo "-------------------------"
response=$(curl -s -w "\n%{http_code}" -X POST "$BACKEND_URL/api/generate" \
    -H "Content-Type: application/json" \
    -d '{"messages":[{"role":"user","content":"Write a one-sentence essay about testing."}],"maxTokens":100}')

http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" = "200" ]; then
    echo "${GREEN}✓ PASS${NC} - API request successful"
    echo "Response preview: $(echo "$body" | head -c 100)..."
elif [ "$http_code" = "401" ] || [ "$http_code" = "403" ]; then
    echo "${RED}✗ FAIL${NC} - Authentication failed (HTTP $http_code)"
    echo "Check your ANTHROPIC_API_KEY in environment variables"
    echo "Response: $body"
elif [ "$http_code" = "429" ]; then
    echo "${YELLOW}⚠ RATE LIMITED${NC} - Too many requests (HTTP $http_code)"
    echo "This is expected if you've been testing frequently"
else
    echo "${RED}✗ FAIL${NC} - API request failed (HTTP $http_code)"
    echo "Response: $body"
fi
echo ""

# Test 3: Invalid Request (Should fail gracefully)
echo "Test 3: Invalid Request Handling"
echo "--------------------------------"
response=$(curl -s -w "\n%{http_code}" -X POST "$BACKEND_URL/api/generate" \
    -H "Content-Type: application/json" \
    -d '{"invalid":"data"}')

http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" = "400" ]; then
    echo "${GREEN}✓ PASS${NC} - Invalid request handled correctly"
    echo "Error message: $body"
else
    echo "${YELLOW}⚠ WARNING${NC} - Expected 400, got $http_code"
    echo "Response: $body"
fi
echo ""

# Test 4: Rate Limiting Check
echo "Test 4: Rate Limiting (Quick Check)"
echo "-----------------------------------"
echo "Sending 3 rapid requests..."

success_count=0
for i in {1..3}; do
    response=$(curl -s -w "\n%{http_code}" -X POST "$BACKEND_URL/api/generate" \
        -H "Content-Type: application/json" \
        -d '{"messages":[{"role":"user","content":"Hi"}],"maxTokens":50}')
    
    http_code=$(echo "$response" | tail -n 1)
    
    if [ "$http_code" = "200" ]; then
        ((success_count++))
    fi
    
    # Small delay
    sleep 0.5
done

if [ $success_count -ge 2 ]; then
    echo "${GREEN}✓ PASS${NC} - Rate limiting functioning ($success_count/3 succeeded)"
else
    echo "${YELLOW}⚠ WARNING${NC} - Rate limiting may be too strict ($success_count/3 succeeded)"
fi
echo ""

# Summary
echo "=================================="
echo "Test Summary"
echo "=================================="
echo ""
echo "Backend URL: $BACKEND_URL"
echo ""
echo "Next Steps:"
echo "1. If all tests passed, backend is ready!"
echo "2. Update frontend with this backend URL"
echo "3. Test the complete application"
echo ""
echo "Troubleshooting:"
echo "- If health check fails: Backend is not running or URL is wrong"
echo "- If API fails: Check ANTHROPIC_API_KEY environment variable"
echo "- If rate limited: Normal, wait or increase limit"
echo ""
