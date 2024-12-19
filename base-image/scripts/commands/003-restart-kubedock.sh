#!/bin/bash

# Function to check if a process is running
is_running() {
    pgrep -f 'kubedock server' > /dev/null 2>&1
}

# Function to restart kubedock
restart_kubedock() {
    if is_running; then
        echo "Stopping kubedock..."
        pkill -f 'kubedock server'
    fi
    echo "Starting kubedock..."
    nohup kubedock server --reverse-proxy --kubeconfig /home/user/.kube/config > /tmp/kubedock.log 2>&1 &
}

# Run the restart function
restart_kubedock