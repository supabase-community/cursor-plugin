# Scripts

## PR Monitor (`monitor-pr.sh`)

A lightweight macOS daemon that polls a GitHub pull request for changes and sends a native notification when something happens (new review, comment, state change, or merge decision).

### How It Works

1. Each run fetches the PR state via `gh pr view`
2. Compares against a cached snapshot in `/tmp/pr-monitor-<PR_NUMBER>.json`
3. If anything changed, sends a macOS notification with a summary and updates the cache
4. On first run, seeds the cache and exits silently

### Prerequisites

- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated
- Python 3 (ships with macOS)
- macOS (uses `osascript` for notifications)

### Configuration

Edit the variables at the top of `monitor-pr.sh` to monitor a different PR:

```bash
REPO="supabase-community/cursor-plugin"   # GitHub owner/repo
PR_NUMBER=25                                # PR number to watch
STATE_FILE="/tmp/pr-monitor-${PR_NUMBER}.json"  # Cache location
```

### Manual Usage

Run the script directly at any time:

```bash
./scripts/monitor-pr.sh
```

- First run seeds the state file — no notification.
- Subsequent runs notify only when the PR state differs from the cache.

To force a fresh baseline (e.g. after you've seen the notification and want to reset):

```bash
rm /tmp/pr-monitor-25.json
./scripts/monitor-pr.sh
```

### Automated Monitoring (launchd)

A launchd agent runs the script every 15 minutes in the background.

**Plist location:** `~/Library/LaunchAgents/com.leonardcosta.pr-monitor.plist`

#### Load (start monitoring)

```bash
launchctl load ~/Library/LaunchAgents/com.leonardcosta.pr-monitor.plist
```

#### Unload (stop monitoring)

```bash
launchctl unload ~/Library/LaunchAgents/com.leonardcosta.pr-monitor.plist
```

#### Check status

```bash
launchctl list | grep pr-monitor
# Output: -  0  com.leonardcosta.pr-monitor
# Column 1: PID (- = not currently running)
# Column 2: last exit code (0 = success)
```

#### View logs

```bash
cat /tmp/pr-monitor.log
```

### Notification Behavior

- **Title:** `PR #25 Update`
- **Body:** `State: OPEN | Reviews: 1 | Comments: 2 | Decision: APPROVED`
- **Sound:** Glass

### Tracked Fields

The monitor detects changes to:

- `state` — OPEN, CLOSED, MERGED
- `reviewDecision` — APPROVED, CHANGES_REQUESTED, REVIEW_REQUIRED
- `commentCount` — total PR-level comments
- `reviewCount` — total review submissions

### Cleanup

To fully remove the monitor:

```bash
launchctl unload ~/Library/LaunchAgents/com.leonardcosta.pr-monitor.plist
rm ~/Library/LaunchAgents/com.leonardcosta.pr-monitor.plist
rm /tmp/pr-monitor-25.json
rm /tmp/pr-monitor.log
```
