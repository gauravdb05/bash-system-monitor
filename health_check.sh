#!/bin/bash

source ./config.env
mkdir -p logs

DATE=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="./logs/health-$(date '+%Y%m%d').log"

echo "[$DATE] Starting health check..." >> "$LOG_FILE"

# Disk Check
DISK=$(df -h "$MOUNT_POINT" | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK" -gt "$DISK_THRESHOLD" ]; then
    echo "[$DATE] ⚠️ Disk usage on $MOUNT_POINT is ${DISK}%" >> "$LOG_FILE"
else
    echo "[$DATE] ✅ Disk usage is OK: ${DISK}%" >> "$LOG_FILE"
fi

# Memory Check
MEM=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')
if [ "$MEM" -gt "$MEM_THRESHOLD" ]; then
    echo "[$DATE] ⚠️ Memory usage is high: ${MEM}%" >> "$LOG_FILE"
else
    echo "[$DATE] ✅ Memory usage is OK: ${MEM}%" >> "$LOG_FILE"
fi

# CPU Check
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | awk -F. '{print $1}')
if [ "$CPU" -gt "$CPU_THRESHOLD" ]; then
    echo "[$DATE] ⚠️ CPU usage is high: ${CPU}%" >> "$LOG_FILE"
else
    echo "[$DATE] ✅ CPU usage is OK: ${CPU}%" >> "$LOG_FILE"
fi

echo "[$DATE] Health check completed." >> "$LOG_FILE"
