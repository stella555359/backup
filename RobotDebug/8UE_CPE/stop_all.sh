#!/bin/bash

# Set the PID file path to the directory where run_all.sh is located
run_all_dir="$(cd "$(dirname "$0")" && pwd)"
echo "run_all_dir is set to: $run_all_dir"

# Check if the PID file exists
pid_file="$run_all_dir/pids.txt"
if [ ! -f "$pid_file" ]; then
    echo "PID file not found. No processes to terminate."
    exit 1
fi

# Terminate all processes listed in the PID file
while read -r pid; do
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        echo "Terminating process (PID: $pid)..."
        kill -9 "$pid"
    fi
done < "$pid_file"

# Remove the PID file
rm -f "$pid_file"

echo "All processes terminated."