#!/bin/bash
# Confirm each site answers HTTP 200 and contains a phrase that proves the real page rendered.
# Each site gets three tries, 20 seconds apart, so one slow moment does not raise an alarm.
fail=0
check() {
  url="$1"; phrase="$2"
  for try in 1 2 3; do
    body=$(mktemp)
    code=$(curl -sS -L -o "$body" -m 25 -w "%{http_code}" "$url" 2>/dev/null || true)
    if [ "$code" = "200" ] && grep -qi -- "$phrase" "$body"; then
      echo "OK    $code  $url"
      rm -f "$body"
      return 0
    fi
    rm -f "$body"
    [ "$try" -lt 3 ] && sleep 20
  done
  echo "FAIL  ${code:-none}  $url  (expected HTTP 200 containing \"$phrase\")"
  echo "::error::$url is down or not rendering (last status: ${code:-none})"
  fail=1
}

check "https://harvestcompanion.com/"          "Harvest Companion"
check "https://demo.harvestcompanion.com/"     "Demo Church"
check "https://companionpipeline.com/"         "Companion Pipeline"
check "https://app.companionpipeline.com/"     "Companion Pipeline"
check "https://demo.companionpipeline.com/"    "Companion Pipeline"

exit $fail
