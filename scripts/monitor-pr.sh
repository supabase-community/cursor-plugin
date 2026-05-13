#!/usr/bin/env bash
# Monitor PR #25 on supabase-community/cursor-plugin for changes.
# Sends a macOS notification when reviews, comments, or state change.

set -o pipefail

REPO="supabase-community/cursor-plugin"
PR_NUMBER=25
STATE_FILE="/tmp/pr-monitor-${PR_NUMBER}.json"

current=$(gh pr view "$PR_NUMBER" --repo "$REPO" \
  --json state,reviewDecision,comments,reviews 2>/dev/null)

if [[ $? -ne 0 || -z "$current" ]]; then
  exit 1
fi

state=$(echo "$current" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps({'state':d['state'],'reviewDecision':d.get('reviewDecision',''),'commentCount':len(d.get('comments',[])),'reviewCount':len(d.get('reviews',[]))}))")

# First run — seed the state file
if [[ ! -f "$STATE_FILE" ]]; then
  echo "$state" > "$STATE_FILE"
  exit 0
fi

previous=$(cat "$STATE_FILE")

if [[ "$state" != "$previous" ]]; then
  pr_state=$(echo "$current" | python3 -c "import sys,json; print(json.load(sys.stdin)['state'])")
  comment_count=$(echo "$current" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('comments',[])))")
  review_count=$(echo "$current" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('reviews',[])))")
  review_decision=$(echo "$current" | python3 -c "import sys,json; print(json.load(sys.stdin).get('reviewDecision','PENDING'))")

  title="PR #${PR_NUMBER} Update"
  body="State: ${pr_state} | Reviews: ${review_count} | Comments: ${comment_count} | Decision: ${review_decision}"

  osascript -e "display notification \"${body}\" with title \"${title}\" sound name \"Glass\""

  echo "$state" > "$STATE_FILE"
fi
