# System Metrics Logging Script

This script logs system metrics (CPU usage and memory usage) to a PostgreSQL database hosted on Render at regular intervals.

## Prerequisites

- A PostgreSQL database hosted on Render.
- PostgreSQL client installed on the server where this script will be executed.
- Bash shell.

## Database Setup

Before running the script, ensure that your PostgreSQL database has a table named `system_metrics` with the following schema:

```sql
CREATE TABLE system_metrics (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL,
    cpu_usage REAL NOT NULL,
    mem_total INTEGER NOT NULL,
    mem_used INTEGER NOT NULL
);
```

## Script Details

### Variables

- `DB_HOST`: The hostname of your Render PostgreSQL database.
- `DB_NAME`: The name of your database.
- `DB_USER`: The username for your database.
- `DB_PASSWORD`: The password for your database.
- `DB_PORT`: The port on which your PostgreSQL database is running.

### Functions

1. **get_system_metrics**: This function retrieves the current system metrics:
   - CPU usage
   - Total memory
   - Used memory
   - Timestamp
   The metrics are printed as a comma-separated string.

2. **log_metrics_to_db**: This function logs the system metrics to the PostgreSQL database. It:
   - Calls `get_system_metrics` to get the current metrics.
   - Parses the metrics string into individual variables.
   - Constructs an SQL `INSERT` command.
   - Executes the command using `psql`.

### Main Loop

The script runs indefinitely in a loop, logging metrics to the database every 30 seconds.

## Usage

1. **Clone or download the script**:
   Save the script to a file, e.g., `log_system_metrics.sh`.

2. **Make the script executable**:
   ```bash
   chmod +x log_system_metrics.sh
   ```

3. **Run the script**:
   ```bash
   ./log_system_metrics.sh
   ```

### Example Script

```bash
#!/bin/bash

# Database connection details
DB_HOST="####"
DB_NAME="####"
DB_USER="####"
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

# Schedule the script to run at intervals (e.g., every 5 minutes)
while true; do
  log_metrics_to_db
  sleep 30 # 30 seconds
done
```



By following these instructions, you can set up and run the script to log system metrics to your Render-hosted PostgreSQL database.
