# Implementation Roadmap: Weeks 2-4 (Strategic Automations)

**Updated:** 2026-06-10 (Post-Decisions)  
**Status:** Planning Phase (Ready to Execute)

---

## Decision Record (Final)

**Your Answers:**
- ✅ LM Studio: **Integrate into Continue** (secondary fallback)
- ✅ Google Live Studio: **YES** (autonomous video generation for site content)
- ✅ Browser Automation: **YES** (aider + Playwright for form testing)
- ✅ Conversion Feedback Loops: **YES** (daily CRO runs on 5 consumers)
- ✅ Thinking Budget: **NO** to `/effort xhigh` override + **YES for Cline R1** (DeepSeek R1 as reasoning model)

---

## WEEK 2: Reproducibility & Advanced Model Setup

### 2.1: LM Studio Integration (High Priority)
**Goal:** Wire LM Studio as Continue fallback chain

**Current state:**
- Ollama: Primary (qwen2.5-coder:7b)
- LM Studio: Not integrated
- Fallback: None (if Ollama fails, no backup)

**Implementation:**
```yaml
# .continue/config.yaml additions:
models:
  - name: "LM Studio Qwen 14B (Fallback)"
    provider: openai
    model: qwen/qwen2.5-coder-14b
    apiBase: http://172.17.176.1:1234/v1
    apiKey: lm-studio
    roles: [chat, edit]
    defaultCompletionOptions:
      maxTokens: 8192
```

**Fallback chain:**
1. Try Ollama qwen2.5-coder:7b (local, fast)
2. If fails → Try LM Studio qwen2.5-coder:14b (local, more capable)
3. If both fail → Fall back to DeepSeek Chat (cloud)

**Effort:** 30 min (edit Continue config + test)

---

### 2.2: Cline R1 Support (High Priority)
**Goal:** Add DeepSeek R1 as Cline's architecture/reasoning model

**Current state:**
- Cline default: Claude Sonnet + medium thinking
- No reasoning model option

**Implementation:**
**File:** `.cursor-server/data/User/globalStorage/.../globalState.json`

Add to Cline configuration:
```json
{
  "cline.models": [
    {
      "provider": "anthropic",
      "model": "claude-sonnet-4-6",
      "apiKey": "$ANTHROPIC_API_KEY",
      "actModeReasoningEffort": "medium"
    },
    {
      "provider": "openai",
      "model": "deepseek-reasoner",
      "apiBase": "https://api.deepseek.com/v1",
      "apiKey": "$DEEPSEEK_API_KEY",
      "actModeReasoningEffort": "xhigh",
      "label": "R1 - Extended Thinking"
    }
  ],
  "cline.modelSelection": {
    "architecture": "deepseek-reasoner",
    "routine": "claude-sonnet-4-6"
  }
}
```

**Workflow:**
```
Routine task → Claude Sonnet (medium) = $0.01/request
Architecture → DeepSeek R1 (xhigh) = $0.30/request (full thinking)
```

**Cost model:**
- 70% Claude ($0.01 each) = $0.35/day
- 30% R1 ($0.30 each) = $0.45/day
- **Total:** $0.80/day ($24/month) — same cost, better results

**Effort:** 1 hour (UI config + testing)

---

### 2.3: Unified Bootstrap Script
**Goal:** Reproducible setup on new machine

**File:** `scripts/setup-ide-agents.sh` (new)

Handles:
- [ ] Secrets management (symlink to .profile)
- [ ] VS Code extensions installation
- [ ] Cline globalState setup
- [ ] Roo preferences
- [ ] Continue config propagation
- [ ] MCP server sync
- [ ] GCP ADC login

**Effort:** 2 hours (script + testing)

---

### 2.4: Cline Settings Snapshots
**Goal:** Auto-backup Cline config after sessions

**Implementation:**
Add to `package.json`:
```json
{
  "scripts": {
    "backup:cline-config": "cp ~/.cursor-server/data/User/globalStorage/saoudrizwan.claude-dev/settings/globalState.json .backup/cline-globalstate-$(date +%s).json"
  }
}
```

Also document rollback procedure.

**Effort:** 30 min

---

### 2.5: Settings Registry in Repo
**Goal:** All agent settings persisted + versioned

**Files to add:**
- `.backup/cline-globalstate-LATEST.json` (snapshot)
- `.continue/config.yaml` (already there)
- `docs/ROO-AGENT-SETUP.md` (Roo preferences)
- `docs/GEMINI-SETUP.md` (Gemini CLI config)

**Effort:** 1 hour

---

## WEEK 3: Google Live Studio Integration

### 3.1: Research Google Live Studio APIs
**Goal:** Understand autonomous video generation capability

**Tasks:**
- [ ] Check if Google Vertex AI has video generation
- [ ] Identify API endpoint + auth (GCP ADC)
- [ ] Cost per video generation
- [ ] Integration method (MCP server vs CLI tool)

**Candidates:**
- Google Vertex AI Generative Models (check for video)
- Runway (third-party, might need API key)
- ElevenLabs + image generation + stitching

**Effort:** 2 hours (research + decision)

---

### 3.2: Create MCP Video Generation Server
**Goal:** Autonomous video generation for site content

**Implementation:**
```bash
# New MCP server: ~/.local/mcp/video-generation/

# Capabilities:
- generate_video(prompt, duration, style, aspectRatio)
  → Returns video file path
  → Saves to output/videos/
  → Can chain with Playwright for screenshots

# Example use case:
/task "Generate 30-second promo video for excavationky.com roofing services"
→ Create script with Markdown
→ Generate images via Vertex AI
→ Compose into video
→ Upload to site
```

**Integration:**
Add to `config/mcp-servers.json`:
```json
{
  "video-generation": {
    "type": "stdio",
    "command": "node",
    "args": ["~/.local/mcp/video-generation/index.js"]
  }
}
```

**Effort:** 3 days (implementation + testing + optimization)

---

### 3.3: Wire to Agent Workflows
**Goal:** Agents can autonomously generate video content

**Agents who get access:**
- Cline (main content generator)
- Claude Code (via skill)
- Codex (automation)

**Effort:** 1 day (integration)

---

## WEEK 4: Browser Automation + Conversion Loops

### 4.1: Aider + Playwright Integration
**Goal:** Autonomous browser testing + form filling

**Use cases:**
1. **QA Testing** — Automated contact form validation across 5 sites
2. **Competitor Analysis** — Fill out competitor forms, capture responses
3. **Checkout Testing** — Test payment flow for accuracy
4. **SEO Validation** — Check canonical tags, meta, schema across pages

**Implementation:**
```bash
# npm scripts:
npm run test:forms:aider         # Auto-test all contact forms
npm run test:checkout:aider      # Test checkout flow
npm run test:competitor:aider    # Fill competitor forms
npm run validate:seo:aider       # Check SEO markup
```

**Effort:** 2 days (script + test cases + edge cases)

---

### 4.2: Conversion Feedback Loop Enablement
**Goal:** Daily autonomous CRO optimization on 5 consumers

**Current state:**
- Conversion loop engine exists
- Config: `config/conversion-feedback-loop.json`
- Status: Idle (not running daily)

**Implementation:**
1. Enable daily runs via cron:
```bash
# Daily 2am UTC run (captures overnight traffic)
0 2 * * * cd ~/projects/Kunida-Rules-Network && npm run conversion-loop:run -- --consumers ExcavationKY,ASBBuilders,BCT,UnionImpact,ElegantStitch
```

2. Each run:
   - Collects conversion metrics
   - Analyzes friction points
   - Proposes A/B tests
   - Logs recommendations
   - Measures lift

3. Manual approval gate (once/week):
   - Review top 3 recommendations
   - Approve tests
   - Monitor for 7 days
   - Measure impact

**Config:**
```json
{
  "consumers": [
    "ExcavationKY",
    "ASBBuilders", 
    "BCT",
    "UnionImpact",
    "ElegantStitch"
  ],
  "runHour": 2,
  "approvalFrequency": "weekly",
  "successMetric": "qualified-leads"
}
```

**Effort:** 1 day (enable + monitoring setup)

---

### 4.3: Conversion Loop Monitoring Dashboard
**Goal:** Weekly review of CRO recommendations

**Dashboard includes:**
- Top 3 recommendations (ranked by potential lift)
- Historical lift measurements
- Approved vs rejected tests
- Cost per conversion baseline
- Trend analysis

**File:** `docs/qa/conversion-loop-status.json` (updated daily)

**Effort:** 1 day (dashboard + UI)

---

## EXECUTION PLAN (Parallel Where Possible)

### Week 2 (Days 1-5)
- **Mon-Tue:** LM Studio integration + Cline R1 support (parallel)
- **Wed:** Unified bootstrap script
- **Thu:** Settings snapshots + registry
- **Fri:** Validation + backlog refinement

### Week 3 (Days 6-10)
- **Mon-Tue:** Live Studio API research + decision
- **Wed-Thu:** MCP video generation server (coding)
- **Fri:** Integration + initial testing

### Week 4 (Days 11-15)
- **Mon-Tue:** Aider + Playwright integration
- **Wed-Thu:** Conversion loop enablement
- **Fri:** Monitoring dashboard + go-live

---

## Effort Estimates (Total)

| Task | Effort | Impact | Priority |
|------|--------|--------|----------|
| LM Studio integration | 0.5d | High (fallback) | P0 |
| Cline R1 support | 1d | High (reasoning) | P0 |
| Bootstrap script | 2d | High (reproducibility) | P1 |
| Live Studio R&D | 2d | Medium (research) | P2 |
| Video generation MCP | 3d | High (automation) | P1 |
| Browser automation | 2d | High (QA) | P1 |
| Conversion loops | 1d | High (revenue) | P1 |
| Monitoring dashboards | 1d | Medium (ops) | P2 |

**Total:** ~12 days (3 weeks of 4-day sprints)

---

## Strategic Alignment

**Phase 1 (Week 2):** Foundation
- Reproducible setup ✅
- Advanced models (R1) ✅
- Local fallback chains ✅

**Phase 2 (Week 3-4):** Automations
- Autonomous video generation 🎬
- Browser QA automation 🤖
- Daily CRO optimization 💰

**Outcome:**
- **Reproducibility:** Setup any machine in 1 hour
- **Model leverage:** Use best model for each task (Claude routine, R1 architecture, Qwen fallback)
- **Automation:** Video + form testing + CRO loops run autonomously
- **Revenue impact:** Estimated +5-10% conversion lift from daily CRO

---

## Decisions Needed (During Execution)

1. **Live Studio provider:** Google Vertex, Runway, or other?
2. **Video generation quality:** Speed (1min) vs Quality (5min generation time)?
3. **Conversion loop approval:** Manual weekly or auto-apply small tests?
4. **Browser automation scope:** Just forms, or full checkout + competitor analysis?

---

## Files to Create/Modify

**New files:**
- `scripts/setup-ide-agents.sh`
- `scripts/integrations/video-generation-mcp.mjs`
- `scripts/integrations/aider-browser-automation.mjs`
- `docs/VIDEO-GENERATION-SETUP.md`
- `docs/BROWSER-AUTOMATION-SETUP.md`
- `docs/CONVERSION-LOOP-GUIDE.md`

**Modify:**
- `.continue/config.yaml` (LM Studio fallback)
- `.cursor-server/globalState.json` (Cline R1 model)
- `config/mcp-servers.json` (video generation + browser automation)
- `package.json` (new npm scripts)
- `config/conversion-feedback-loop.json` (enable daily runs)

---

## Success Metrics

**Week 2:**
- ✅ Cline can switch to R1 for architecture tasks
- ✅ Continue has fallback chain (Ollama → LM Studio → Cloud)
- ✅ Bootstrap script reproducible on new machine
- ✅ Settings versioned in repo

**Week 3:**
- ✅ Video generation MCP working
- ✅ Agents can generate autonomous video content
- ✅ First batch of 5 promo videos generated

**Week 4:**
- ✅ Form validation automation running
- ✅ Competitor analysis forms filled autonomously
- ✅ Conversion feedback loops running daily
- ✅ Weekly CRO recommendations dashboard live

---

## Blockers / Risks

| Risk | Mitigation |
|------|-----------|
| Live Studio API not available | Fallback to Runway or ElevenLabs |
| LM Studio connectivity issues | Add retry logic + fallback to cloud |
| Cline R1 API limits | Monitor usage, set spending limits |
| Video generation slow | Use lower quality/resolution first |
| Conversion loop false positives | Manual approval gate (weekly review) |
| Browser automation brittleness | Use explicit waits + error handling |

---

## Next Immediate Steps

**Execute in order:**

1. ✅ **Week 1 Finalization** (TODAY)
   - [ ] You: Click Cline UI settings (actModeReasoningEffort: medium, maxRequests: 200)
   - [ ] You: Restart VS Code
   - [ ] Me: Run health check validation
   - [ ] Me: Confirm all ✅

2. 🚀 **Week 2 Kickoff (Tomorrow)**
   - [ ] LM Studio integration (Continue config update)
   - [ ] Cline R1 support (add to globalState)
   - [ ] Bootstrap script creation
   - [ ] Initial testing

---

## Budget & Cost Impact

**Current:** ~$81/month (Claude + APIs)  
**With R1 hybrid:** ~$85/month (small increase for reasoning)  
**Video generation:** +$5-10/month (Vertex AI or Runway)  
**Conversion optimization:** +$2/month (automation, no APIs needed)  

**Total:** ~$90-100/month  
**Revenue upside:** +5-10% conversion lift ($500-2000+/month for your clients)

**ROI:** Highly positive if conversion lift materializes.

---

**Status:** Ready to execute. Awaiting Week 1 finalization + your go-ahead.
