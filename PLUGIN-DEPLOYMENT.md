# Plugin Development & Deployment Workflow

## Overview
All WordPress plugins are centrally managed in this repo and deployed to client sites through a controlled workflow. **Always work locally first, then push to repo, then to clients.**

## Plugin Organization

### `/plugins/wordpress-library/canonical_shared/Kunida-Rules-Network/`
**Shared plugins** used across all network sites:
- `kunida-wp-ops-cockpit` — Marketing/Ops dashboard (v0.2.5+)
- `kunida-license-gate` — License entitlement gate
- `kunida-seo-controls` — SEO readbacks & controls
- `kunida-admin-cleanup` — Admin UI cleanup
- `kunida-plugin-updater` — Plugin update orchestration

### `/plugins/wordpress-library/consumer_specific/[Client]/`
**Client-specific plugins**:
- `Reliable-Outcomes-Excavation/`
  - `reliable-outcomes-estimate-form` — Custom estimate form
  - `reliable-outcomes-site-controls` — ROE-specific site controls
- `Business-Computer-Technicians/`
- `American-Saddlebred-Builders-LLC/`
- `Union-Impact/`

### `/plugins/wordpress/` (Local dev environment)
**Local copies** for development and testing. Keep in sync with library before committing.

## Development Workflow

### 1. Local Development
```bash
# Edit plugin locally
nano /plugins/wordpress/kunida-wp-ops-cockpit/kunida-wp-ops-cockpit.php

# Test changes locally (in WP test env)
# Verify functionality, no errors, no warnings
```

### 2. Sync to Library
```bash
# Copy latest version to canonical location
cp -r plugins/wordpress/kunida-wp-ops-cockpit/* \
  plugins/wordpress-library/canonical_shared/Kunida-Rules-Network/kunida-wp-ops-cockpit/
```

### 3. Commit to Git
```bash
git add plugins/wordpress-library/canonical_shared/Kunida-Rules-Network/kunida-wp-ops-cockpit/
git commit -m "feat: Add high-priority UX improvements to Kunida Ops Cockpit

- Dashboard Widget: Compact KPI display
- Settings Page: Module visibility toggles
- Tab Persistence: Save last visited tab
- Export API: REST endpoint for data export"

git push origin main
```

### 4. Deploy to Client
**Do NOT deploy directly to clients.** Clients pull from this repo via:

#### Option A: Git Pull (Recommended)
```bash
ssh forge@[client-ip]
cd /var/www/[client-domain]/wp-content/plugins/
git clone https://github.com/kunidadesigns/Kunida-Rules-Network.git kn-sync
cp -r kn-sync/plugins/wordpress-library/canonical_shared/Kunida-Rules-Network/* .
sudo chown -R www-data:www-data kunida-*
```

#### Option B: Composer/Packagist
Define plugins in `composer.json` per client and pull from GitHub releases.

#### Option C: Manual SCP (For Quick Fixes)
```bash
scp -i ~/.ssh/client-key -r plugins/wordpress-library/canonical_shared/Kunida-Rules-Network/[plugin] \
  forge@[client-ip]:/var/www/[client-domain]/wp-content/plugins/
```

## Before Each Commit

- [ ] Plugin tested locally without errors
- [ ] Version number bumped in plugin header
- [ ] Synced from `/wordpress/` to `/wordpress-library/canonical_shared/`
- [ ] .secrets files NOT included (use `.env` instead)
- [ ] No vendor folders, build artifacts, or node_modules
- [ ] git commit message describes user-facing changes

## Plugin Update Checklist

```
Plugin: [name]
Version: [new version]

- [ ] Feature/fix implemented locally
- [ ] Tested in WordPress admin
- [ ] No PHP errors, warnings
- [ ] No security vulnerabilities (use `composer audit`)
- [ ] Update version in plugin header
- [ ] Copy to wordpress-library/canonical_shared/
- [ ] git add/commit/push
- [ ] Create GitHub Release tag if major release
- [ ] Document breaking changes in CHANGELOG
- [ ] Notify clients of update via [communication channel]
```

## Clients & Deployment Matrix

| Client | Repo | Plugin Updates | Deployment Method |
|--------|------|---|---|
| BCT (businesscomputertechnicians.com) | Kunida-Rules-Network | Auto/Manual | Git pull or SCP |
| ROE (excavationky.com) | Reliable-Outcomes-Excavation | Manual | Git clone + merge |
| ASB (asb-builders.com) | Kunida-Rules-Network | Manual | Composer |
| Union Impact | Kunida-Rules-Network | Manual | SCP |
| Elegant Stitch | Kunida-Rules-Network | Manual | SCP |

## Emergency Hotfix Procedure

1. Create feature branch: `git checkout -b hotfix/critical-bug`
2. Apply fix locally & test thoroughly
3. Sync to library
4. Commit & push to main: `git push origin hotfix/critical-bug && git checkout main && git merge hotfix/critical-bug`
5. Deploy immediately to affected clients via SCP
6. Document in CHANGELOG with "HOTFIX" label

## Secrets & Credentials

**NEVER commit to plugins:**
- API keys, passwords, tokens
- Vendor secrets
- Personal/customer data

**Instead:**
- Use WordPress constants (wp-config.php)
- Use `.env` files (git-ignored)
- Use environment variables
- Store in encrypted `.secrets/` directory

Example in plugin:
```php
$api_key = defined( 'KUNIDA_API_KEY' ) ? KUNIDA_API_KEY : getenv( 'KUNIDA_API_KEY' );
```

## Resources
- GitHub: https://github.com/kunidadesigns/Kunida-Rules-Network
- ROE Repo: /home/david/projects/Reliable-Outcomes-Excavation
- Plugin Docs: `CLAUDE.md` in repo root
- Client Servers: See `.secrets/[client].env`
