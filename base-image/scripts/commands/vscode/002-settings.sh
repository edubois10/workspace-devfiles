#!/bin/bash
# This script is used to manage the VSCode settings for a project.
# It performs the following steps:
# 1. Defines the path to the settings file.
# 2. Defines the path to the settings.json file in the .vscode directory.
# 3. If the settings.json file exists, it merges the new settings from the settings file into the existing settings.json file.
# 4. Defines the path to the .code-workspace file.
# 5. If the .code-workspace file exists, it checks if the file has a "settings" field.
# 6. If the "settings" field exists, it merges the new settings from the settings file into the existing settings.
# 7. If the "settings" field does not exist, it adds the new settings from the settings file to the .code-workspace file.


# Define the path to the recommendations file
SETTINGS_FILE="settings.json"

# Define the path to the settings.json file
SETTINGS_JSON="$PROJECT_SOURCE/.vscode/settings.json"

# If the settings.json file exists, update it with the new settings
if [ -f "$SETTINGS_JSON" ]; then
    tmpfile=$(mktemp)
    jq -s '.[0] * .[1]' $SETTINGS_FILE $SETTINGS_JSON > "$tmpfile" && mv "$tmpfile" $SETTINGS_JSON
fi

CODE_WORKSPACES_FILE="$PROJECT_SOURCE/.code-workspace"

# If the .code-workspace file does not exist, create it
if [ ! -f "$CODE_WORKSPACES_FILE" ]; then
    echo '{"settings": {}}' > "$CODE_WORKSPACES_FILE"
fi

if [ -f "$CODE_WORKSPACES_FILE" ]; then
    tmpfile=$(mktemp)
    if [ $(jq 'has("settings")' "$CODE_WORKSPACES_FILE") == "true" ]; then
        jq ".settings = (.settings // {}) + $(jq '.' $SETTINGS_FILE)" $CODE_WORKSPACES_FILE > "$tmpfile" && mv "$tmpfile" $CODE_WORKSPACES_FILE
    else
        jq ".settings = $(jq '.' "$SETTINGS_FILE")" "$CODE_WORKSPACES_FILE" > "$tmpfile" && mv "$tmpfile" $CODE_WORKSPACES_FILE
    fi
fi