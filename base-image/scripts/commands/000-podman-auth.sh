#!/bin/bash

# This script copies the .dockerconfigjson file to the auth.json file
# in the containers directory. If the .dockerconfigjson file does not exist,
# it will not copy the file and will not produce an error.

# Check if the .dockerconfigjson file exists
if [ -f "/home/user/.docker/.dockerconfigjson" ]; then
    # Copy the .dockerconfigjson file to the auth.json file
    cp /home/user/.docker/.dockerconfigjson /home/user/.config/containers/auth.json
    # Standard docker config
    if [ ! -f "/home/user/.docker/config.json" ]; then
        if [ -w "/home/user/.docker" ]; then
            ln -s /home/user/.config/containers/auth.json /home/user/.docker/config.json
        else
            echo "Warning: /home/user/.docker is not writable. Skipping symlink creation."
        fi
    fi
fi