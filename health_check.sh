#!/bin/bash
# =============================================================
# health_check.sh — Linux Server Health Monitor
# Checks CPU, memory, disk, and Apache every time it runs.
# Cron will call this every 5 minutes.
# =============================================================

LOG_FILE="/home/kiran/health-monitor/health.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Thresholds — if usage crosses these, we log a WARNING
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=80

echo "--------------------------------------------" >> "$LOG_FILE"
echo "[$TIMESTAMP] Health Check Started" >> "$LOG_FILE"

# --- 1. CPU CHECK ---
# `top -bn1` runs `top` once in batch mode (non-interactive)
# We extract the idle % and subtract from 100 to get usage %
CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d. -f1)
CPU_USAGE=$((100 - CPU_IDLE))
echo "[$TIMESTAMP] CPU Usage: ${CPU_USAGE}%" >> "$LOG_FILE"

if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
    echo "[$TIMESTAMP] WARNING: CPU usage is ${CPU_USAGE}% — above threshold ${CPU_THRESHOLD}%" >> "$LOG_FILE"
fi

# --- 2. MEMORY CHECK ---
# `free -m` shows memory in megabytes
# We calculate: used/total * 100 = usage %
MEM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
MEM_USED=$(free -m | awk '/^Mem:/{print $3}')
MEM_USAGE=$(( (MEM_USED * 100) / MEM_TOTAL ))
echo "[$TIMESTAMP] Memory Usage: ${MEM_USAGE}% (${MEM_USED}MB / ${MEM_TOTAL}MB)" >> "$LOG_FILE"

if [ "$MEM_USAGE" -gt "$MEM_THRESHOLD" ]; then
    echo "[$TIMESTAMP] WARNING: Memory usage is ${MEM_USAGE}% — above threshold ${MEM_THRESHOLD}%" >> "$LOG_FILE"
fi

# --- 3. DISK CHECK ---
# `df -h /` checks the root partition
# We parse the "Use%" column and remove the % sign
DISK_USAGE=$(df -h / | awk 'NR==2{print $5}' | cut -d% -f1)
echo "[$TIMESTAMP] Disk Usage: ${DISK_USAGE}%" >> "$LOG_FILE"

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "[$TIMESTAMP] WARNING: Disk usage is ${DISK_USAGE}% — above threshold ${DISK_THRESHOLD}%" >> "$LOG_FILE"
fi

# --- 4. APACHE HEALTH CHECK ---
# `systemctl is-active` returns "active" if running, "inactive" if stopped
APACHE_STATUS=$(systemctl is-active apache2)
echo "[$TIMESTAMP] Apache Status: ${APACHE_STATUS}" >> "$LOG_FILE"

if [ "$APACHE_STATUS" != "active" ]; then
    echo "[$TIMESTAMP] WARNING: Apache is DOWN. Attempting auto-restart..." >> "$LOG_FILE"
    sudo systemctl start apache2
    # Check if restart worked
    NEW_STATUS=$(systemctl is-active apache2)
    echo "[$TIMESTAMP] Apache after restart: ${NEW_STATUS}" >> "$LOG_FILE"
fi

echo "[$TIMESTAMP] Health Check Completed" >> "$LOG_FILE"
