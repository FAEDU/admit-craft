# AdmitCraft Backend Deployment Guide

## Quick Start (5 minutes)

### Option 1: Deploy to Vercel via GitHub (RECOMMENDED - Easiest)

**Prerequisites:**
- GitHub account with your code pushed
- Anthropic API key

**Steps:**

1. **Sign up at Vercel.com**
   - Go to https://vercel.com
   - Click "Sign Up" → "Continue with GitHub"
   - Authorize Vercel to access your repositories

2. **Import Your Repository**
   - Click "Add New..." → "Project"
   - Find your `admitcraft` repository
   - Click "Import"

3. **Configure Root Directory**
   - **IMPORTANT**: Click "Edit" next to Root Directory
   - Select `backend` folder
   - This tells Vercel where your backend code is

4. **Add Environment Variable**
   - Click "Environment Variables"
   - Add:
     - **Name**: `ANTHROPIC_API_KEY`
     - **Value**: Your API key from console.anthropic.com
   - Click "Add"

5. **Deploy**
   - Click "Deploy"
   - Wait 1-2 minutes for build
   - ✅ Backend deployed!

6. **Get Your Backend URL**
   - Copy URL: `https://admitcraft-backend-xxxx.vercel.app`
   - Test health check: `https://your-url.vercel.app/health`
   - Should return: `{"status":"ok","service":"AdmitCraft API"}`

**Auto-Deploy Setup:**
- Every push to GitHub main branch = Automatic deployment
- No manual steps needed after initial setup!

### Option 2: Deploy to Vercel CLI

1. **Install Vercel CLI**
   ```bash
   npm i -g vercel
   ```

2. **Deploy from Backend Directory**
   ```bash
   cd backend
   vercel --prod
   ```

3. **Set Environment Variable**
   - Go to Vercel dashboard
   - Settings → Environment Variables
   - Add `ANTHROPIC_API_KEY`
   - Redeploy: `vercel --prod`

### Option 3: Deploy to Render via GitHub

1. **Go to Render.com**
   - Sign up at https://render.com with GitHub

2. **New Web Service**
   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Select `backend` as root directory

3. **Configure**
   - Build Command: `npm install`
   - Start Command: `npm start`
   - Add environment variable: `ANTHROPIC_API_KEY`

4. **Deploy**
   - Render will build and deploy
   - Auto-deploys on every GitHub push

### Option 4: Run Locally (For Development)

1. **Install Dependencies**
   ```bash
   cd backend
   npm install
   ```

2. **Create .env file**
   ```bash
   cp .env.example .env
   # Edit .env and add your ANTHROPIC_API_KEY
   ```

3. **Start Server**
   ```bash
   npm start
   # Server runs on http://localhost:3000
   ```

## Backend API Endpoints

### Health Check
```
GET /health
Response: {"status": "ok", "service": "AdmitCraft API"}
```

### Generate/Edit Essay
```
POST /api/generate
Headers: Content-Type: application/json
Body: {
  "messages": [
    {"role": "user", "content": "Your prompt here"}
  ],
  "maxTokens": 4000
}
```

## Security Features

✅ **Rate Limiting**: 20 requests per hour per IP
✅ **Input Validation**: Prevents excessive content
✅ **CORS Protection**: Configurable allowed origins
✅ **API Key Hidden**: Never exposed to frontend
✅ **Error Handling**: Safe error messages

## Getting Your Anthropic API Key

1. Go to https://console.anthropic.com
2. Sign up / Log in
3. Go to API Keys section
4. Create new key
5. Copy and save securely

## Monitoring & Logs

**Vercel**: View logs in dashboard under "Functions" tab
**Render**: View logs in dashboard
**Local**: Console output

## Cost Estimation

- **Anthropic API**: ~$0.003 per essay (Sonnet 4)
- **Hosting**: Free tier available (Vercel: 100GB/month, Render: 750 hours/month)
- **Expected**: $0-30/month for 10,000 essays

## Update Frontend Configuration

After deploying backend, update frontend:

```javascript
const API_URL = 'https://your-backend-url.vercel.app';
```

## Troubleshooting

**Error: API Key Invalid**
- Check environment variable in Vercel/Render dashboard
- Verify API key at console.anthropic.com
- Redeploy after adding/updating variables

**Error: CORS**
- Update CORS settings in server.js if needed
- Vercel automatically handles CORS for serverless functions

**Error: Rate Limit**
- Increase RATE_LIMIT in server.js
- Or implement database-based rate limiting

**Error: Build Fails**
- Check Node.js version (need >=18.0.0)
- Verify package.json is in backend directory
- Check deployment logs for specific errors

## Production Checklist

- [ ] Code pushed to GitHub
- [ ] Backend deployed (Vercel/Render)
- [ ] API key configured
- [ ] Health check endpoint working (returns 200)
- [ ] Frontend updated with backend URL
- [ ] Test essay generation works
- [ ] Monitor logs for errors
- [ ] Set up alerts for downtime (optional)

## GitHub Integration Benefits

✅ **Auto-Deploy**: Push to GitHub → Automatic deployment
✅ **Version Control**: All changes tracked
✅ **Rollback**: Easy to revert to previous versions
✅ **Collaboration**: Team can contribute via pull requests
✅ **CI/CD**: GitHub Actions for testing
✅ **Free Hosting**: Both Vercel and Render have free tiers

---

**Estimated Setup Time**: 5-10 minutes
**Recommended Platform**: Vercel (easiest GitHub integration)
**Monthly Cost**: Free tier sufficient for testing
