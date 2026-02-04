# AdmitCraft Backend API

Secure API proxy server for AdmitCraft essay generation.

## Quick Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and add your Anthropic API key:
```
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxx
```

### 3. Run Server

**Development:**
```bash
npm run dev
```

**Production:**
```bash
npm start
```

Server runs on `http://localhost:3000`

## API Endpoints

### Health Check
```
GET /health
```
Returns: `{"status":"ok","service":"AdmitCraft API"}`

### Generate/Edit Essay
```
POST /api/generate
Content-Type: application/json

{
  "messages": [
    {"role": "user", "content": "Your prompt here"}
  ],
  "maxTokens": 4000
}
```

## Features

- ✅ Secure API key handling
- ✅ Rate limiting (20 requests/hour per IP)
- ✅ Input validation
- ✅ Error handling
- ✅ CORS enabled
- ✅ Production-ready

## Deployment

See `DEPLOYMENT.md` for detailed deployment instructions.

### Quick Deploy to Railway

1. Push to GitHub
2. Create new project on Railway
3. Connect GitHub repo
4. Add `ANTHROPIC_API_KEY` environment variable
5. Deploy!

## Configuration

### Rate Limiting
Edit `server.js` line 23:
```javascript
const RATE_LIMIT = 20; // requests per hour
```

### Port
Default: 3000
Override with `PORT` environment variable

### CORS
By default, allows all origins. For production, configure in `server.js` line 18.

## Testing

Test health endpoint:
```bash
curl http://localhost:3000/health
```

Test essay generation:
```bash
curl -X POST http://localhost:3000/api/generate \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Write a short essay about AI"}]}'
```

## Monitoring

View logs:
- **Railway**: Dashboard → Deployments → View Logs
- **Vercel**: Dashboard → Functions → Logs
- **Local**: Check console output

## Troubleshooting

**Error: API Key Invalid**
- Check `.env` file has correct key
- Verify key at console.anthropic.com

**Error: Port already in use**
- Change PORT in `.env`
- Or kill process: `kill -9 $(lsof -t -i:3000)`

**Error: Module not found**
- Run `npm install` again
- Delete `node_modules` and reinstall

## Security

- API key never exposed to frontend
- Rate limiting prevents abuse
- Input validation on all requests
- Error messages don't leak sensitive info

## License

MIT - ForeignAdmits

## Support

For issues, check:
1. Server logs
2. Health endpoint status
3. API key validity
4. Rate limits
