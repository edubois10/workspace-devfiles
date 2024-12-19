#!/bin/bash

# This script is used to reload the devfile in an OpenShift DevWorkspace.
# It performs the following steps:
# 1. Checks if the user is authenticated in OpenShift.
# 2. Checks if the devfile.yaml exists.
# 3. Removes metadata and schemaVersion from the devfile.yaml.
# 4. Wraps the devfile content in a 'template' and 'spec' structure.
# 5. Sets the 'started' field to false to trigger a restart.
# 6. Patches the DevWorkspace with the modified devfile to initiate a restart.
# 7. Sets the 'started' field back to true to complete the restart.

# Check if the user is authenticated in OpenShift
if ! oc whoami &> /dev/null; then
    echo "You are not logged in to OpenShift. Please log in and try again."
    exit 1
fi

# Check if the devfile.yaml exists
devfile="devfile.yaml"
if [ ! -f devfile.yaml ] && [ ! -f .devfile.yaml ]; then
    read -p "Neither devfile.yaml nor .devfile.yaml exist. Please provide the path to the devfile: " devfile_path
    if [ ! -f "$devfile_path" ]; then
        echo "The provided devfile path does not exist. Please ensure the file is present and try again."
        exit 1
    fi
    devfile="$devfile_path"
else
    [ -f .devfile.yaml ] && devfile=".devfile.yaml"
fi

export TIMESTAMP=$(date +%s)

# Patch the annotation with the devfile content
yq -o=json '.' $devfile | jq -Rs '{"che.eclipse.org/devfile": .}' | yq '{"annotations": .}' - | yq '{"metadata": .}' - > /tmp/devfile-annotations-$TIMESTAMP.yaml
oc patch devworkspaces/${DEVWORKSPACE_NAME} --type=merge -p "$(cat /tmp/devfile-annotations-$TIMESTAMP.yaml)"

# Patch the template with the devfile content
yq 'del(.metadata)' $devfile | yq 'del(.schemaVersion)' - | yq '{"template": .}' - | yq '{"spec": .}' - > /tmp/devfile-$TIMESTAMP.yaml
yq -i '.spec.started = false' /tmp/devfile-$TIMESTAMP.yaml
oc patch devworkspaces/${DEVWORKSPACE_NAME} --type=merge -p "$(cat /tmp/devfile-$TIMESTAMP.yaml)"

# Set the 'started' field back to true to complete the restart
oc patch devworkspaces/${DEVWORKSPACE_NAME} --type=merge -p '{"spec": {"started": true}}'