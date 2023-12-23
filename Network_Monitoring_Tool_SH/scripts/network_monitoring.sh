#!/usr/bin/env bash

# Enhanced Network Monitoring Script for Multiple Interfaces
LOG_FILE="/var/log/network_monitor.log"
SAMPLE_INTERVAL=1 # Hwo often to sample network samples stats (in seconds)

# Function to log messages
log_message(){
  echo "$(date '+%Y:%m:%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to calculate and log network statistics for a given interface
monitor_network(){
  local interface=$1
  local rx_bytes_before=$(cat /sys/class/net/"$interface"/statistics/rx_bytes)
  local tx_bytes_before=$(cat /sys/class/net/"$interface"/statistics/tx_bytes)

  sleep "$SAMPLE_INTERVAL"

  local rx_bytes_after=$(cat /sys/class/net/"$interface"/statistics/rx_bytes)
  local tx_bytes_after=$(cat /sys/class/net/"$interface"/statistics/tx_bytes)

  local rx_rate=$(( (rx_bytes_after-rx_bytes_before) / SAMPLE_INTERVAL ))
  local tx_rate=$(( (tx_bytes_after-tx_bytes_before) / SAMPLE_INTERVAL ))

  log_message "$interface - RX: $rx_rate bytes/sec, TX: $tx_rate bytes/sec"

}

# Ensure the user is running the script with root privileges
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root or with sudo"
fi

# Main loop
log_message "Starting network monitoring an all interfaces..."
while true; do
  for interface in /sys/class/net/*; do
    # Extrac just the interface name, not the full path
    interface=$(basename "$interface")

    # Optionally, skip certain interfaces like 'lo' (loopback)
    if [ "$interface" == 'lo' ]; then
      continue
    fi

    monitor_network "$interface"
  done
  sleep 5 # Rest for a short while before checking again
done

