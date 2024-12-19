#!/bin/bash
# This script is used to manage the VSCode extensions for a project.
# It performs the following steps:
# 1. Defines the path to the extensions file.
# 2. Defines the path to the extensions.json file in the .vscode directory.
# 3. Ensures the .vscode directory exists.
# 4. If the extensions.json file exists, it merges the new extensions from the extensions file into the existing extensions.json file.
# 5. Defines the path to the .code-workspace file.
# 6. If the .code-workspace file exists, it checks if the file has an "extensions" field.
# 7. If the "extensions" field exists, it merges the new extensions from the extensions file into the existing extensions.
# 8. If the "extensions" field does not exist, it adds the new extensions from the extensions file to the .code-workspace file.


# Define the path to the recommendations file
EXTENSIONS_FILE="extensions.json"

# Define the path to the extensions.json file
EXTENSIONS_JSON="$PROJECT_SOURCE/.vscode/extensions.json"

# Ensure the .vscode directory exists
mkdir -p "$PROJECT_SOURCE/.vscode"

# If the extensions.json file exists, update it with the new settings
if [ -f "$EXTENSIONS_JSON" ]; then
    tmpfile=$(mktemp)
    if jq -e '.recommendations' $EXTENSIONS_JSON > /dev/null; then
        jq '.recommendations |= (. + $new | unique)' --argjson new "$(jq '.recommendations' $EXTENSIONS_FILE)" $EXTENSIONS_JSON > "$tmpfile"
    else
        jq '.recommendations = $new' --argjson new "$(jq '.recommendations' $EXTENSIONS_FILE)" $EXTENSIONS_JSON > "$tmpfile"
    fi
    mv "$tmpfile" $EXTENSIONS_JSON
fi

CODE_WORKSPACES_FILE="$PROJECT_SOURCE/.code-workspace"

# If the .code-workspace file does not exist, create it
if [ ! -f "$CODE_WORKSPACES_FILE" ]; then
    echo '{"extensions": {"recommendations": []}}' > "$CODE_WORKSPACES_FILE"
fi

if [ -f "$CODE_WORKSPACES_FILE" ]; then
    tmpfile=$(mktemp)
    if [ $(jq 'has("extensions")' "$CODE_WORKSPACES_FILE") == "true" ]; then
        jq ".extensions.recommendations = ((.extensions.recommendations // []) + $(jq '.recommendations' $EXTENSIONS_FILE) | unique)" $CODE_WORKSPACES_FILE > "$tmpfile" && mv "$tmpfile" $CODE_WORKSPACES_FILE
    else
        jq ".extensions.recommendations = $(jq '.recommendations' "$EXTENSIONS_FILE")" "$CODE_WORKSPACES_FILE" > "$tmpfile" && mv "$tmpfile" $CODE_WORKSPACES_FILE
    fi
fi