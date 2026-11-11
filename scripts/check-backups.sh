#!/bin/bash
# Each server's nightly backup script asks the off-site (Backblaze) repository for its newest
# snapshot and publishes that timestamp. Fail if any is missing or older than 26 hours.
fail=0
max_age_hours=26
check() {
  name="$1"; url="$2"
  text=$(curl -sS -m 25 "$url" 2>/dev/null || true)
  stamp=$(printf '%s\n' "$text" | sed -n 's/^latest_snapshot_utc=//p' | head -1)
  if [ -z "$stamp" ]; then
    echo "FAIL  $name: no backup status found at $url"
    echo "::error::$name backup status is missing"
    fail=1
    return
  fi
  then_s=$(date -u -d "$stamp" +%s 2>/dev/null || echo 0)
  now_s=$(date -u +%s)
  age_h=$(( (now_s - then_s) / 3600 ))
  if [ "$then_s" -eq 0 ] || [ "$age_h" -ge "$max_age_hours" ]; then
    echo "FAIL  $name: newest off-site backup is $stamp (${age_h}h old)"
    echo "::error::$name has no backup in the last ${max_age_hours} hours (newest: $stamp)"
    fail=1
  else
    echo "OK    $name: newest off-site backup $stamp (${age_h}h old)"
  fi
}

check "Harvest Companion LMS" "https://harvestcompanion.com/backup-status.txt"
check "Companion Pipeline"    "https://companionpipeline.com/backup-status.txt"

exit $fail
