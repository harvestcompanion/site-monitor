# Site monitor

Scheduled health checks for the Harvest Companion sites. No secrets live here – every check reads a public page.

| Check | When | What it does |
|---|---|---|
| Uptime | Every 15 minutes | Loads harvestcompanion.com, demo.harvestcompanion.com, companionpipeline.com, app.companionpipeline.com and demo.companionpipeline.com. Each must answer HTTP 200 and show its expected title. Three tries before failing. |
| Backups | Daily, 05:15 UTC | Reads each server's `backup-status.txt` (written by the nightly backup script after asking Backblaze for its newest snapshot). Fails if the newest backup is more than 26 hours old. |
| Certificates | Daily, 05:15 UTC | Fails if any SSL certificate is within 14 days of expiring. |

## Alerts

When a run fails, GitHub emails the account owner. This depends on one setting staying on:
GitHub → Settings → Notifications → Actions → “Email” checked (and “Only notify for failed workflows” is fine).

To test the alert: Actions → Uptime check → Run workflow → type `yes` in the box.

## Why this repository is public

GitHub gives public repositories unlimited free Actions minutes. A 15-minute schedule uses about
2,900 minutes a month, which is more than the free allowance for private repositories. Nothing here is
private: only public web addresses.

## Adding a site

Add one line to `scripts/check-sites.sh` (and `scripts/check-certs.sh`), and a row in HarvestOps `sites.yaml`.
