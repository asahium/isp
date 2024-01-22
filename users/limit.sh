#!/bin/bash

# User Configuration
USERNAME=$1
SPEED_LIMIT=$2
DATA_LIMIT_GB=$3
INTERFACE=$USERNAME

# Convert data limit from GB to bytes for comparison
DATA_LIMIT_BYTES=$((DATA_LIMIT_GB * 1024 * 1024 * 1024))

# Function to check data usage
check_data_usage() {
    local usage=$(ip -s link show $INTERFACE | awk '/RX|TX/{getline; print $1}' | paste -sd+ | bc)
    echo $usage
}

# Create a new virtual network interface
sudo ip link add $INTERFACE type dummy
sudo ip link set $INTERFACE up

# Apply speed limit with tc
sudo tc qdisc add dev $INTERFACE root tbf rate $SPEED_LIMIT burst 32kbit latency 400ms

# Initialize data usage
DATA_USAGE=$(check_data_usage)

# Monitor the data usage
while true; do
    sleep 60  # Check every minute
    NEW_USAGE=$(check_data_usage)
    if [ $NEW_USAGE -gt $DATA_LIMIT_BYTES ]; then
        echo "Data limit exceeded for $USERNAME"
        # Here, implement the action to be taken when limit is exceeded
        # For example, disable the interface: sudo ip link set $INTERFACE down
        break
    fi
    DATA_USAGE=$NEW_USAGE
done

echo "User $USERNAME created with a speed limit of $SPEED_LIMIT and a data limit of $DATA_LIMIT_GB GB."
