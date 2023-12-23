#!/usr/bin/env bash

# Enhanced System Performance Monitoring Script

# Configuration
LOG_FILE="/var/log/system_performance.log"
SAMPLE_INTERVAL=5 # How ofter to sample system stats (in seconds)

# Function to log messages
log_message(){
  echo "$(date '+%Y:%m:%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# check for required commands/tools
check_requirements(){
  local missing_counter=0
  for command in vmstat iostat mpstat df; do
    if ! command -v $command &> /dev/null; then
      log_message "Command not found: $command"
      let missing_counter++
    fi
  done
  if [ $missing_counter -gt 0 ]; then
    logmessage "Missing $missing_counter required commands. Please install them first."
    exit 1
  fi
}

# Monitor CPU Usage
monitor_cpu(){
  log_message "CPU Usage (mpstat):"
  mpstat 1 1 | tee -a "$LOG_FILE"
}

# Monitor Memory Usage
monitor_memory(){
  log_message "Memory Usage (vmstat):"
  vmstat 1 2 | tail -n 1 | tee -a "$LOG_FILE"
}

# Monitor Disk I/O
monitor_disk(){
  log_message "Disk I/O (iostat):"
  iostat -xz 1 1 | tee -a "$LOG_FILE"
}

# Monitor Disk Space Usage
monitor_disk_space(){
  log_message "Disk Space Usage (df):"
  df -h | tee -a "$LOG_FILE"
}

# Main monitoring function
monitor_system(){
  while true; do
    monitor_cpu
    monitor_memory
    monitor_disk
    monitor_disk_space
    sleep "$SAMPLE_INTERVAL"
  done
}

# Ensure the script is running with root privileges
if [[ $EUID -ne 0 ]]; then
  log_message "Please run as root or with sudo."
  exit 1
fi

# Check for required tools
check_requirements

# Start monitoring
log_message "Starting system performance monitoring..."
monitor_system















