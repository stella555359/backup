#!/bin/bash

# Check if a directory is passed as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Navigate to the target directory
target_dir="$1"
if [ ! -d "$target_dir" ]; then
    echo "Error: Directory $target_dir does not exist."
    exit 1
fi

cd "$target_dir"

# Clean up stale shell processes for scripts in the target directory before launching new ones.
for script in *.sh; do
    if [ -f "$script" ]; then
        pkill -f "/bin/sh ./$script" 2>/dev/null || true
    fi
done

# Set the PID file path to the directory where run_all.sh is located
run_all_dir="$(cd "$(dirname "$0")" && pwd)"
echo "run_all_dir is set to: $run_all_dir"
pid_file="$run_all_dir/pids.txt"
> "$pid_file"

# Find and execute all .sh files in the background
for script in *.sh; do
    if [ -f "$script" ]; then
        chmod +x "$script"  # Ensure the script is executable
        nohup ./$script > "${script%.sh}.log" 2>&1 &
        echo $! >> "$pid_file"  # Record the PID of the background process
        echo "Running $script in the background. Logs: ${script%.sh}.log"
    fi
done

echo "All scripts in $target_dir are running in the background."