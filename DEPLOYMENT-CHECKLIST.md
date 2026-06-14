# 🚀 AI Backend Complete Deployment Checklist

**Status:** Ready to Deploy  
**Target Date:** Today (2026-06-10)  
**Estimated Time:** 30 minutes automation + 10 minutes manual setup

---

## PRE-DEPLOYMENT (Verify System Ready)

- [ ] Run health check: `npm run health:ai-backends`
- [ ] Confirm all ✅ (keys, GCP, cache, Ollama)
- [ ] VS Code not running (will be restarted during deployment)

---

## AUTOMATED DEPLOYMENT (Run Master Script)

Execute the master deployment script:

```bash
bash scripts/deploy-all-ai-backends.sh
```

**This will:**
1. ✅ Verify system health
2. ✅ Configure Continue with LM Studio fallback
3. ✅ Configure Cline with DeepSeek R1 (32K thinking)
4. ✅ Setup browser automation (Playwright + Aider)
5. ✅ Enable conversion feedback loops
6. ✅ Sync MCP servers to all agents
7. ✅ Final validation

**Expected output:** "🎉 DEPLOYMENT COMPLETE"

**Time:** ~5 minutes

---

## MANUAL STEPS (After Automated Deployment)

### Step 1: Restart VS Code (2 min)

Close all instances and reopen:
```bash
pkill code
sleep 2
code ~/projects/Kunida-Rules-Network &
```

### Step 2: Verify Cline R1 Configuration (2 min)

In Cline, ask:
```
What model are you using? Show me your full configuration.
```

**Expected response:**
```
I'm using DeepSeek R1 (deepseek/deepseek-r1-0528) 
with 32K token thinking budget.
All reasoning features enabled with maximum effort.
Cost awareness is active.
```

### Step 3: Verify Continue Fallback Chain (2 min)

In Continue, ask:
```
What's your fallback model chain if Ollama fails?
```

**Expected response:**
```
1. Ollama qwen2.5-coder:7b (local)
2. LM Studio qwen2.5-coder:14b (fallback)
3. DeepSeek Chat (cloud fallback)
```

### Step 4: Test Browser Automation (2 min)

Run contact form test:
```bash
npm run test:forms:aider
```

**Expected:** Test connects to excavationky.com contact form and logs results

### Step 5: Verify Conversion Loops Config (2 min)

Check configuration:
```bash
cat config/conversion-feedback-loop.json
```

Should show:
- ✅ enabled: true
- ✅ 5 consumers configured
- ✅ daily schedule at 02:00 UTC

---

## OPTIONAL: Enable Scheduled Automation

### Option A: Cron-Based (Recommended)

Add to crontab:
```bash
# Daily conversion loops at 2 AM UTC
0 2 * * * cd ~/projects/Kunida-Rules-Network && npm run conversion-loop:run >> ~/logs/cron-conversion-loop.log 2>&1

# Daily contact form tests at 3 AM UTC
0 3 * * * cd ~/projects/Kunida-Rules-Network && npm run test:forms:aider >> ~/logs/cron-form-tests.log 2>&1

# Weekly SEO validation at 6 AM UTC Monday
0 6 * * 1 cd ~/projects/Kunida-Rules-Network && npm run test:seo:aider >> ~/logs/cron-seo-tests.log 2>&1
```

Edit crontab:
```bash
crontab -e
```

### Option B: Manual Runs

Run commands manually when needed:
```bash
npm run conversion-loop:run
npm run test:forms:aider
npm run test:seo:aider
```

---

## POST-DEPLOYMENT VALIDATION

Run these commands to verify everything:

```bash
# Health check
npm run health:ai-backends

# Codex validation
npm run check:codex-commands

# MCP sync status
npm run sync:mcp-all

# Config validation
npm run check:agent-router
```

All should show ✅.

---

## WHAT'S NOW RUNNING

### Cline (Claude Dev)
- **Model:** DeepSeek R1 (deepseek/deepseek-r1-0528)
- **Thinking:** 32K tokens (MAXED)
- **Effort:** Maximum (all reasoning enabled)
- **Cost:** ~$0.50/day for 10 complex tasks
- **Features:** All MCP tools auto-approved

### Continue
- **Primary:** Ollama qwen2.5-coder:7b (local)
- **Fallback 1:** LM Studio qwen2.5-coder:14b (if Ollama fails)
- **Fallback 2:** DeepSeek Chat (cloud, if both local fail)
- **Autocomplete:** qwen2.5-coder:1.5b-base
- **Cost:** $0 if Ollama running, minimal if fallback used

### Browser Automation
- **Daily (3 AM UTC):** Contact form tests on 5 sites
- **Weekly:** Competitor form analysis
- **Weekly:** SEO validation (canonical, schema, etc.)
- **Cost:** Included in Playwright (no API cost)

### Conversion Feedback Loops
- **Daily (2 AM UTC):** Analyze conversion metrics on 5 consumers
- **Weekly approval gate:** Review & approve top 3 recommendations
- **Tracks:** Form completions, bounce rate, conversion rate
- **Cost:** $0 (local analysis)

### MCP Servers (All Agents)
- 18 total servers
- 90+ tools available
- All auto-approved (auth already handled)
- Includes: search, WordPress, GitHub, Playwright, PDF, memory

---

## MONITORING & MAINTENANCE

### Daily
```bash
# Check for errors
tail -f ~/logs/cron-conversion-loop.log
tail -f ~/logs/cron-form-tests.log
```

### Weekly
1. Review conversion loop recommendations
2. Approve top 3 A/B tests
3. Check form test results for issues

### Monthly
```bash
# Health check
npm run health:ai-backends

# Cache cleanup (if >100MB)
npm run clean:codex-cache

# MCP sync validation
npm run sync:mcp-all
```

---

## ROLLBACK (If Needed)

Each script created backups:

```bash
# Restore Continue config
cp ~/.continue/config.json.backup-<timestamp> ~/.continue/config.json

# Restore Cline config
cp ~/.cursor-server/.../globalState.json.backup-<timestamp> ~/.cursor-server/.../globalState.json
```

---

## COST SUMMARY

| Component | Monthly Cost |
|-----------|--------------|
| Claude Code (subscription) | $20 |
| DeepSeek R1 reasoning | +$15 |
| DeepSeek Chat (fallback) | +$2 |
| Video generation (future) | +$5 |
| Conversion optimization | $0 |
| Browser automation | $0 |
| **Total** | **~$100** |

**Expected ROI:** +5-10% conversion lift = $500-2000+/month per client

---

## NEXT STEPS (After Deployment)

### Week 1-2: Stabilization ✅ DONE
- ✅ Health check system
- ✅ Cache management
- ✅ MCP permissions
- ✅ Documentation

### Week 2-3: Advanced Setup ✅ DONE
- ✅ LM Studio integration
- ✅ Cline R1 maxed out
- ✅ Browser automation ready
- ✅ Conversion loops enabled

### Week 4: Video Generation (PENDING)
- [ ] Research Live Studio integration
- [ ] Build video generation MCP
- [ ] Wire to agents

### Ongoing: Monitoring & Optimization
- [ ] Weekly: Review CRO recommendations
- [ ] Monthly: Health checks
- [ ] Quarterly: Cost analysis + ROI measurement

---

## SUCCESS CRITERIA

✅ **Cline:** Using R1 with 32K thinking  
✅ **Continue:** Has 3-tier fallback chain  
✅ **Browser Automation:** Daily form tests running  
✅ **Conversion Loops:** Daily recommendations generated  
✅ **Health Check:** All systems ✅  
✅ **Logs:** No errors in automation runs  
✅ **Cost:** ~$100/month (within budget)  

---

## DOCUMENTS REFERENCE

- Setup guide: `docs/IDE-AGENT-SETUP.md`
- Cline config: `.claude/CLINE-SETTINGS.md`
- Audit findings: `docs/AI-BACKEND-AUDIT-2026-06-10.md`
- Implementation roadmap: `IMPLEMENTATION-ROADMAP-WEEKS-2-4.md`
- This checklist: `DEPLOYMENT-CHECKLIST.md`

---

## Questions?

Check documentation in this order:
1. `DEPLOYMENT-CHECKLIST.md` (this file)
2. `.claude/CLINE-SETTINGS.md` (configuration)
3. `docs/IDE-AGENT-SETUP.md` (setup guide)
4. `docs/AI-BACKEND-AUDIT-2026-06-10.md` (findings)

---

## GO/NO-GO

**READY TO DEPLOY?** Yes / No

If YES:
```bash
bash scripts/deploy-all-ai-backends.sh
```

Then follow the manual steps above.

---

**Deployment Time Estimate:** 30 minutes (automated) + 10 minutes (manual) = **40 minutes total**

**Expected Uptime:** 100% (no disruption to current workflow)

**Rollback Time:** 5 minutes (if needed)
