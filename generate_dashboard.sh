#!/bin/bash
# =============================================================
# generate_dashboard.sh
# Reads the last 20 lines of health.log and generates an HTML
# page that Apache will serve at http://127.0.0.1:8080/dashboard.html
# =============================================================

LOG_FILE="/home/kiran/health-monitor/health.log"
OUTPUT_FILE="/var/www/html/dashboard.html"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Read the last 100 lines (covers ~5 check cycles)
LOG_CONTENT=$(tail -n 100 "$LOG_FILE")

# Count warnings
WARNING_COUNT=$(grep -c "WARNING" "$LOG_FILE" || echo 0)

cat > "$OUTPUT_FILE" << HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="refresh" content="60">
  <title>Server Health Dashboard</title>
  <style>
    body { font-family: monospace; background: #0f1117; color: #e2e8f0; margin: 0; padding: 20px; }
    h1 { color: #63b3ed; border-bottom: 1px solid #2d3748; padding-bottom: 10px; }
    .meta { color: #718096; font-size: 13px; margin-bottom: 20px; }
    .warning-badge { background: #c53030; color: white; padding: 2px 10px; border-radius: 12px; font-size: 12px; }
    .ok-badge { background: #276749; color: white; padding: 2px 10px; border-radius: 12px; font-size: 12px; }
    pre { background: #1a202c; border: 1px solid #2d3748; border-radius: 8px; padding: 16px; overflow-x: auto; font-size: 13px; line-height: 1.6; white-space: pre-wrap; }
    .warn-line { color: #fc8181; font-weight: bold; }
    .ok-line { color: #68d391; }
    .info-line { color: #e2e8f0; }
    .divider { color: #4a5568; }
  </style>
</head>
<body>
  <h1>🖥 Server Health Monitor</h1>
  <div class="meta">
    Dashboard generated: $TIMESTAMP &nbsp;|&nbsp;
    Auto-refreshes every 60 seconds &nbsp;|&nbsp;
    Total warnings: <span class="$([ $WARNING_COUNT -gt 0 ] && echo 'warning-badge' || echo 'ok-badge')">$WARNING_COUNT</span>
  </div>
  <pre>
HTML

# Now process each line and add colour-coding
while IFS= read -r line; do
    if echo "$line" | grep -q "WARNING"; then
        echo "    <span class='warn-line'>$(echo "$line" | sed 's/</\&lt;/g; s/>/\&gt;/g')</span>"
    elif echo "$line" | grep -q "----"; then
        echo "    <span class='divider'>$(echo "$line" | sed 's/</\&lt;/g; s/>/\&gt;/g')</span>"
    elif echo "$line" | grep -q "Completed\|Started"; then
        echo "    <span class='ok-line'>$(echo "$line" | sed 's/</\&lt;/g; s/>/\&gt;/g')</span>"
    else
        echo "    <span class='info-line'>$(echo "$line" | sed 's/</\&lt;/g; s/>/\&gt;/g')</span>"
    fi
done <<< "$LOG_CONTENT" >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << HTML
  </pre>
</body>
</html>
HTML

echo "Dashboard generated at $OUTPUT_FILE"
