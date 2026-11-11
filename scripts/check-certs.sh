#!/bin/bash
# Fail if any site's SSL certificate expires within 14 days (they normally renew at 30).
fail=0
warn_days=14
for host in harvestcompanion.com demo.harvestcompanion.com companionpipeline.com app.companionpipeline.com demo.companionpipeline.com; do
  end=$(echo | openssl s_client -servername "$host" -connect "$host:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
  if [ -z "$end" ]; then
    echo "FAIL  $host: could not read certificate"
    echo "::error::$host certificate could not be read"
    fail=1
    continue
  fi
  days=$(( ( $(date -u -d "$end" +%s) - $(date -u +%s) ) / 86400 ))
  if [ "$days" -lt "$warn_days" ]; then
    echo "FAIL  $host: certificate expires in $days days ($end)"
    echo "::error::$host certificate expires in $days days"
    fail=1
  else
    echo "OK    $host: certificate valid for $days more days"
  fi
done
exit $fail
