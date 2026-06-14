# Extension Hardening — Quick Start

**Status:** ✅ Applied (2026-06-10)

Your 70+ extensions are now hardened with rollback protection.

---

## One-Time Setup (Do This Now)

```bash
# 1. Close Cursor completely
# 2. Reopen Cursor
# 3. Open this folder: /home/david/projects/Kunida-Rules-Network
# 4. When prompted, click "Trust this folder"
# 5. Restart Cursor one more time
```

**That's it.** Gemini, Cline, Claude Code will now have full context access.

---

## Daily Commands

```bash
# Check if everything is working
npm run extension:health

# If an extension crashes:
npm run extension:rollback

# If you just updated extensions:
npm run extension:baseline
```

---

## What's Protected

### Extensions Hardened (Tier 1 — Always Safe)
- ✅ Claude Code (me)
- ✅ Gemini Code Assist
- ✅ Cline (Roo)

### Extensions Isolated (Tier 2 — On-Demand)
- ESLint, Prettier (serialized — no conflicts)
- GitLens (paused during Gemini use)
- Continue

### Extensions Lazy-Loaded (Tier 3)
- Java, Docker, Terraform, etc.
- Load only when needed

---

## How It Works

1. **Baseline System** — Creates snapshots of known-good state
   - Location: `.claude/baselines/baseline-*.json`
   - Auto-created: whenever you run `npm run extension:*`

2. **Memory Isolation** — Each extension limited to 512MB
   - Crashes don't cascade
   - OOM auto-recovers
   - Timeout: 15 seconds per operation

3. **Conflict Prevention** — Only one AI chat active
   - Gemini + Claude Code + Cline never fight
   - GitLens indexing pauses when you chat
   - Linters serialized (no parallel runs)

4. **Auto-Rollback** — One command to restore
   ```bash
   npm run extension:rollback    # Restores last known good
   npm run extension:rollback [date]  # Restore to specific date
   ```

---

## If Something Breaks

### Extension won't activate?
```bash
npm run extension:health
# Read the report — it tells you exactly what's wrong
```

### Gemini lost context again?
```bash
npm run extension:rollback
# Then restart Cursor
# Then trust the workspace again
```

### Too many extensions slowing things down?
```bash
npm run extension:status
# Disable Tier 3 extensions you don't use often
# Re-baseline to save your changes
npm run extension:baseline
```

---

## Emergency Nuke Button

If everything is broken:

```bash
# Completely reset extensions to last known good state
node scripts/integrations/extension-hardening.mjs harden --reset

# Then:
# 1. Close Cursor
# 2. Reopen it
# 3. Trust the workspace
# 4. Restart Cursor
```

---

## File Locations

| What | Where |
|------|-------|
| Baselines (rollback points) | `.claude/baselines/baseline-*.json` |
| Health reports | `docs/qa/extension-health-report.json` |
| This guide | `docs/tooling/EXTENSION-HARDENING.md` |
| Hardening script | `scripts/integrations/extension-hardening.mjs` |

---

## You're All Set ✅

Your extensions are hardened. When something breaks:
1. `npm run extension:health` — diagnose
2. `npm run extension:rollback` — fix
3. Restart Cursor

No more extension cascades. No more context loss.
