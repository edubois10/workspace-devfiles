#!/bin/bash
# This script sets appropriate permissions on Kubernetes config file
# Note: Restricts read access to owner only for security

if [ -f /home/user/.kube/config ]; then
    chmod 600 /home/user/.kube/config
fi