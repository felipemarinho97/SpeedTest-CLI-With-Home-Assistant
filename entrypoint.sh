#!/bin/sh

# Create log files
touch /var/log/cron.log
touch /var/log/speedtest.log

# Validate the CRON_SCHEDULE environment variable
if [ -z "$CRON_SCHEDULE" ]; then
  CRON_SCHEDULE="0 * * * *"
  echo "CRON_SCHEDULE is not set. Using default value of \"$CRON_SCHEDULE\" (every hour)." 
fi
if ! echo "$CRON_SCHEDULE" | grep -qE '^([0-9*/,\-]+\s+){4}[0-9*/,\-]+$'; then
  echo "\"$CRON_SCHEDULE\" is not a valid cron expression. Exiting..."
  exit 1
fi

# Create the crontab file
echo "${CRON_SCHEDULE} /app/run-speedtest.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/speedtest-cron
chmod 0644 /etc/cron.d/speedtest-cron

# Apply cron job
echo "Applying cron job..."
crontab /etc/cron.d/speedtest-cron

# Load the environment variables
printenv | grep -v "no_proxy" >> /etc/environment

# Start cron
echo "Starting cron..."
cron

# Follow both log files
echo "Starting log monitoring..."
tail -f /var/log/cron.log /var/log/speedtest.log

