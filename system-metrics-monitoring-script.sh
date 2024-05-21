#!/bin/bash

# Database connection details
DB_HOST="#####"
DB_NAME="#####"
DB_USER="#####"
DB_PASSWORD="####"
DB_PORT="####"

# Function to get system metrics
get_system_metrics() {
  CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
  MEM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
  MEM_USED=$(free -m | awk '/^Mem:/{print $3}')
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  echo "$TIMESTAMP,$CPU_USAGE,$MEM_TOTAL,$MEM_USED"
}

# Function to log metrics to the database
log_metrics_to_db() {
  METRICS=$(get_system_metrics)
  IFS=',' read -r TIMESTAMP CPU_USAGE MEM_TOTAL MEM_USED <<< "$METRICS"

  PSQL_CMD="INSERT INTO system_metrics (timestamp, cpu_usage, mem_total, mem_used) VALUES ('$TIMESTAMP', $CPU_USAGE, $MEM_TOTAL, $MEM_USED);"

  PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -d $DB_NAME -U $DB_USER -p $DB_PORT -c "$PSQL_CMD"
}

# Schedule the script to run at intervals (e.g., every 30 seconds)
while true; do
  log_metrics_to_db
  sleep 30 # 30 seconds
done