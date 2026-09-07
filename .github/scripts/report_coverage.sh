#!/usr/bin/env bash
# Parse coverage/lcov.info and update a GitHub Gist with a coverage JSON badge.
# Requires: GITHUB_TOKEN env var with gist scope, lcov.info at coverage/lcov.info

set -euo pipefail

GIST_ID="${GIST_ID:?Set GIST_ID env var}"
LCOV_FILE="coverage/lcov.info"

if [ ! -f "$LCOV_FILE" ]; then
  echo "No lcov.info found at $LCOV_FILE"
  exit 1
fi

# Extract line coverage percentage from LCOV summary
LINES_FOUND=$(grep -m1 '^LH:' "$LCOV_FILE" | cut -d: -f2)
LINES_TOTAL=$(grep -m1 '^LF:' "$LCOV_FILE" | cut -d: -f2)

if [ -z "$LINES_FOUND" ] || [ -z "$LINES_TOTAL" ] || [ "$LINES_TOTAL" -eq 0 ]; then
  echo "Could not parse coverage data"
  exit 1
fi

PCT=$((LINES_FOUND * 100 / LINES_TOTAL))

# Color: red <50, yellow 50-79, green >=80
if [ "$PCT" -ge 80 ]; then
  COLOR="4c1"
elif [ "$PCT" -ge 50 ]; then
  COLOR="dfb317"
else
  COLOR="e05d44"
fi

# Determine label
if [ "$PCT" -eq 100 ]; then
  LABEL="coverage"
elif [ "$PCT" -ge 80 ]; then
  LABEL="coverage"
else
  LABEL="coverage"
fi

JSON_PAYLOAD=$(cat <<EOF
{
  "files": {
    "coverage.json": {
      "content": "{\"schemaVersion\":1,\"label\":\"${LABEL}\",\"message\":\"${PCT}%\",\"color\":\"${COLOR}\"}"
    }
  }
}
EOF
)

echo "Coverage: ${PCT}% (${LINES_FOUND}/${LINES_TOTAL} lines)"

curl -s -X PATCH \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD" \
  "https://api.github.com/gists/${GIST_ID}"

echo ""
echo "Gist updated successfully."
