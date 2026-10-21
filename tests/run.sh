#!/usr/bin/env bash
# Auto-generated test harness — run after cloning to verify the build.
set -uo pipefail
FAIL=0

echo "-- syntax/build check --"
if mkdir -p posts && printf '# Test Post\n\nBody text.\n' > posts/2026-01-01-test.md && ruby lumen-pack.rb posts site; then echo "  ok"; else echo "  FAIL"; FAIL=1; fi

echo "-- functional check --"
OUT="$(mkdir -p posts && printf '# Test Post\n\nBody.\n' > posts/2026-01-01-test.md && ruby lumen-pack.rb posts site 2>&1)"
if echo "$OUT" | grep -qF -- 'Built 1 post(s) into site/'; then
  echo "  ok   - contains: Built 1 post(s) into site/"
else
  echo "  FAIL - expected to contain: Built 1 post(s) into site/"
  echo "  got: $OUT"
  FAIL=1
fi

if [ "$FAIL" = "1" ]; then echo; echo "FAILED"; exit 1; fi
echo; echo "All tests passed."
