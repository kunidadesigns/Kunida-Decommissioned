# Kunida Ops Central — Deployment & Integration Guide

## Overview

Kunida Ops Central is a production-ready API service for monitoring, managing, and optimizing all Astro sites in the Kunida network. It provides real-time metrics, deployment tracking, and multi-site analytics.

## Architecture Decision

**Why this approach is best:**

1. **Centralized** — Single source of truth for all Astro projects
2. **Real-time** — Webhook-driven updates (not polling every 5 minutes)
3. **Scalable** — Works for 1 or 100+ sites without modification
4. **Secure** — OAuth for GitHub, JWT tokens, webhook verification
5. **Maintainable** — Separation of concerns (API ≠ Dashboard)
6. **Flexible** — Can be self-hosted or deployed to Vercel/DigitalOcean

## Infrastructure Components

```
Kunida Ops Central Service
├── Node.js/Express API
│   ├── REST endpoints for metrics
│   ├── Webhook receivers (real-time)
│   ├── JWT authentication
│   └── Database layer (SQLite)
├── Database (SQLite)
│   ├── Sites, deployments, metrics
│   ├── Users & permissions
│   ├── Alerts & audit logs
│   └── Webhook history
└── External Integrations
    ├── GitHub (OAuth + webhooks)
    ├── Vercel (API + webhooks)
    ├── Netlify (API + webhooks)
    ├── Google Analytics 4
    └── npm registry (dependencies)

Astro Dashboard Frontend (separate Astro site)
├── Real-time metrics display
├── Multi-site overview
├── Settings & integrations
└── API calls to Central Service

Per-Site Config (minimal)
├── astro-ops.config.json
├── Environment variables
└── Build hooks
```

## Deployment Options

### Option 1: DigitalOcean App Platform (Recommended)

**Why this is best:**
- Cost-effective ($12-15/month)
- Auto-scaling
- Built-in GitHub integration
- Environment variables managed
- No Docker knowledge needed

**Setup:**
```bash
# 1. Create DigitalOcean App
# 2. Connect GitHub repo (Kunida-Rules-Network)
# 3. Set environment variables from .env
# 4. Deploy

# Result: https://kunida-ops-central-xxx.ondigitalocean.app
```

**Steps:**
1. Go to https://cloud.digitalocean.com/apps
2. Click "Create Apps"
3. Connect GitHub repo
4. Set build command: `npm install && npm run build`
5. Set run command: `npm run start`
6. Add environment variables (from `.env.example`)
7. Deploy

### Option 2: Vercel (Fastest Deploy)

**Why:** Already using Vercel for BCT and other Astro sites

**Limitation:** Serverless functions have limits (databases need replication)

**Setup:**
```bash
# Would require adapting to Vercel Functions
# More complex but faster cold starts
```

### Option 3: Self-Hosted on DigitalOcean Droplet

**Why:** Full control, good for high-volume usage

**Setup:**
```bash
# 1. Create Ubuntu 22.04 droplet ($4-6/month)
# 2. SSH in and run:
curl -sSL https://get.docker.com | sh
git clone https://github.com/kunidadesigns/Kunida-Rules-Network.git
cd Kunida-Rules-Network/apps/kunida-ops-central
docker build -t kunida-ops-central .
docker run -d -p 3000:3000 -e NODE_ENV=production kunida-ops-central
```

## Setup Checklist

### Step 1: Prepare Environment

```bash
# Clone the repo
git clone https://github.com/kunidadesigns/Kunida-Rules-Network.git
cd apps/kunida-ops-central

# Copy environment template
cp .env.example .env

# Edit .env with your credentials (see below)
nano .env
```

### Step 2: Get API Credentials

#### GitHub App
1. Go to https://github.com/settings/apps/new
2. Fill in:
   - **App name:** `kunida-ops-github`
   - **Homepage URL:** `https://your-ops-domain.com`
   - **Webhook URL:** `https://your-ops-domain.com/webhooks/github`
   - **Webhook Secret:** Generate one (random 32+ chars)
3. Permissions:
   - Repository: read:contents, read:metadata, read:pull_requests
4. Events: push, pull_request
5. Create App
6. Copy to `.env`:
   - `GITHUB_APP_ID` (from "App ID")
   - `GITHUB_APP_PRIVATE_KEY` (generate & download)
   - `GITHUB_APP_WEBHOOK_SECRET` (from webhook)

#### Vercel API Token
1. Go to https://vercel.com/account/tokens
2. Create token: `kunida-ops`
3. Copy to `.env`:
   - `VERCEL_API_TOKEN`

#### Netlify API Token
1. Go to https://app.netlify.com/user/applications
2. Create token: `kunida-ops`
3. Copy to `.env`:
   - `NETLIFY_API_TOKEN`

#### Google Analytics 4
1. Go to https://analytics.google.com → Admin → Data Streams
2. Get `Measurement ID`
3. Create Service Account: https://console.cloud.google.com
4. Copy to `.env`:
   - `GA4_PROPERTY_ID`
   - `GA4_MEASUREMENT_ID`
   - `GA4_API_SECRET`

### Step 3: Local Testing

```bash
# Install dependencies
npm install

# Initialize database
npm run db:init

# Start development server
npm run dev

# Test health endpoint
curl http://localhost:3000/health
# Expected: {"status":"ok","timestamp":"..."}
```

### Step 4: Deploy to DigitalOcean App Platform

**Option A: Via Web UI**
1. Go to https://cloud.digitalocean.com/apps
2. Click "Create Apps"
3. Select GitHub repo → `Kunida-Rules-Network`
4. Set source directory: `apps/kunida-ops-central`
5. Set build command: `npm install && npm run build`
6. Set run command: `npm run start`
7. Add environment variables from `.env`
8. Deploy

**Option B: Via doctl CLI**
```bash
# Install doctl
# doctl auth init

doctl apps create --spec app.yaml \
  --name kunida-ops-central \
  --github-repo kunidadesigns/Kunida-Rules-Network
```

### Step 5: Configure Webhooks

Once deployed at `https://kunida-ops-central-xxx.ondigitalocean.app`:

#### GitHub
1. Go to https://github.com/settings/apps/kunida-ops-github
2. Set Webhook URL: `https://kunida-ops-central-xxx.ondigitalocean.app/webhooks/github`
3. Test: Push a commit → should see webhook delivery

#### Vercel
1. For each project: Settings → Integrations → Create webhook
2. URL: `https://kunida-ops-central-xxx.ondigitalocean.app/webhooks/vercel`
3. Test: Trigger deployment → should see webhook delivery

#### Netlify
1. For each site: Site Settings → Build & Deploy → Build hooks
2. URL: `https://kunida-ops-central-xxx.ondigitalocean.app/webhooks/netlify`
3. Test: Trigger deploy → should see webhook delivery

## Database

### SQLite (Default - for development)
- File-based database at `./data/kunida-ops.db`
- Good for < 10M records and low-concurrency
- Easy backup: just copy the file

### PostgreSQL (Optional - for production)
For high-volume usage:

```bash
# Create PostgreSQL instance on DigitalOcean
# Update connection string in code
# Run migrations
npm run migrate
```

## Monitoring & Health

### Health Check
```bash
curl https://kunida-ops-central-xxx.ondigitalocean.app/health
```

### Logs
```bash
# DigitalOcean App Platform
doctl apps logs YOUR_APP_ID

# Docker
docker logs kunida-ops-central
```

### Metrics
Prometheus-compatible metrics available at:
```
https://kunida-ops-central-xxx.ondigitalocean.app/metrics
```

## API Endpoints

Once deployed, API is available at:

```
Base URL: https://kunida-ops-central-xxx.ondigitalocean.app/api
```

All endpoints require `Authorization: Bearer <JWT_TOKEN>` header.

**Example:**
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://kunida-ops-central-xxx.ondigitalocean.app/api/sites
```

## Security Considerations

### Secrets Management
- ✅ Never commit `.env` file
- ✅ Use environment variables in production
- ✅ Rotate API tokens every 90 days
- ✅ Use webhook signatures for verification
- ✅ Enable HTTPS only

### Access Control
- ✅ JWT tokens with expiration
- ✅ Role-based access (admin/editor/viewer)
- ✅ Audit logging of all changes
- ✅ Rate limiting on all endpoints

### Data Protection
- ✅ SQL injection protection (prepared statements)
- ✅ CORS properly configured
- ✅ No PII in logs
- ✅ Webhook payload validation

## Troubleshooting

### Database Locked Error
```bash
rm data/kunida-ops.db
npm run db:init
```

### Webhook Signature Mismatch
- Verify webhook secret in GitHub/Vercel/Netlify matches `.env`
- Check signature header format

### API Rate Limits
- GitHub: 5000 req/hour (public), 60 req/hour (anonymous)
- Vercel: 100 req/min
- Netlify: 200 req/min
- Implement exponential backoff for retries

### Performance Issues
- Check database size: `du -h data/kunida-ops.db`
- Archive old deployments older than 90 days
- Upgrade to PostgreSQL for > 1M records

## Next Steps

1. ✅ **Setup** — Follow environment setup above
2. ✅ **Deploy** — Deploy to DigitalOcean App Platform
3. ⬜ **Implement** — API endpoints for sites, deployments, metrics
4. ⬜ **Dashboard** — Build Astro frontend
5. ⬜ **Per-Site Config** — Add `astro-ops.config.json` to Astro projects
6. ⬜ **Notifications** — Setup email alerts for critical issues

## Support

For issues or questions:
- Check README.md in `apps/kunida-ops-central/`
- Review `.env.example` for all configuration options
- Check GitHub Issues for known problems

## Cost Breakdown

| Component | Cost | Notes |
|-----------|------|-------|
| API Service | $12-15/mo | DigitalOcean App Platform |
| Database | Included | SQLite (included in app) |
| Dashboard | $0-10/mo | Astro site (Vercel free tier) |
| GitHub App | Free | Included with repo |
| Monitoring | Free | Built-in health checks |
| **Total** | **$12-25/mo** | Full monitoring for all Astro sites |

## Resources

- [Kunida Ops Central README](./apps/kunida-ops-central/README.md)
- [Express.js Docs](https://expressjs.com/)
- [DigitalOcean App Platform](https://docs.digitalocean.com/products/app-platform/)
- [GitHub REST API](https://docs.github.com/en/rest)
- [Vercel API](https://vercel.com/docs/api)
- [Netlify API](https://docs.netlify.com/api/overview/)
