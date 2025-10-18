#!/bin/bash

set -e

node_version=$(node -v 2>/dev/null) || {
    echo "🚫 Node.js is not installed."
    exit 1
}
npm_version=$(npm -v 2>/dev/null) || {
    echo "🚫 NPM is not installed."
    exit 1
}
initial_pwd=$(pwd)
project_pwd="$HOME/z-tmp"
project_name="my_project"

if [ -d "$project_pwd/$project_name" ]; then
    echo "🚫 Project directory $project_pwd/$project_name already exists."
    exit 1
fi

mkdir -p "$project_pwd/$project_name"
cd "$project_pwd/$project_name" || {
    echo "🚫 Failed to change to $project_pwd/$project_name"
    exit 1
}
touch index.html main.js

npm init -y >/dev/null
npm install --save-dev --save-exact \
    @biomejs/biome \
    postcss postcss-html \
    stylelint stylelint-config-html stylelint-config-recommended \
    stylelint-config-standard stylelint-config-alphabetical-order \
    stylelint-value-no-unknown-custom-properties stylelint-order

npx @biomejs/biome init >/dev/null
curl -L https://gist.githubusercontent.com/philsinatra/910c20ec4d5ffb16ad97350839a6c664/raw/biome.json -o biome.json
curl -L https://gist.githubusercontent.com/philsinatra/3f1bd2e1cb2a4d4408318697400085fe/raw/.htmlhintrc -o .htmlhintrc
curl -L https://gist.githubusercontent.com/philsinatra/3f1bd2e1cb2a4d4408318697400085fe/raw/.stylelintrc.json -o .stylelintrc.json
curl -L https://gist.githubusercontent.com/philsinatra/79a52c69107d7fa899b88aea25f7f295/raw/css-starter.css -o styles.css

if jq . .stylelintrc.json >/dev/null 2>&1; then
    jq '.rules["csstools/value-no-unknown-custom-properties"][1].importFrom = ["./styles.css"]' .stylelintrc.json >temp.json && mv temp.json .stylelintrc.json""
else
    echo "Error: .stylelintrc.json is not valie JSON"
    exit 1
fi

git init

read -p "🐘 Include PHP config? [Y/n] " response
response=${response:-Y}

if [[ ${response:0:1} =~ ^[Yy]$ ]]; then
    curl -L https://gist.githubusercontent.com/philsinatra/3f1bd2e1cb2a4d4408318697400085fe/raw/php-cs-fixer.php -o .php-cs-fixer.php
    curl -L https://gist.githubusercontent.com/philsinatra/3f1bd2e1cb2a4d4408318697400085fe/raw/phpcs.xml -o phpcs.xml
    curl -L https://gist.githubusercontent.com/philsinatra/3f1bd2e1cb2a4d4408318697400085fe/raw/composer.json -o composer.json

    mv index.html index.php

    if ! command -v composer &>/dev/null; then
        echo "❌ Composer is not installed"
        echo "Visit https://getcomposer.org/download/ for installation instructions"
    else
        composer install
    fi
fi

read -p "Create & open project in VSCode? [y/N] " response
response=${response:-N}

if [[ ${response:0:1} =~ ^[Yy]$ ]]; then
    vscode_workspace_file="$project_name.code-workspace"
    echo "🔧 Creating VSCode workspace file: $vscode_workspace_file"
    curl -L https://gist.githubusercontent.com/philsinatra/3f1bd2e1cb2a4d4408318697400085fe/raw/project.code-workspace

    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$vscode_workspace_file" 2>/dev/null || echo "⚠️ Could not open VSCode workspace (macOS-specific command)"
    else
        echo "⚠️ 'open' command is macOS-specific. Please open $vscode_workspace_file manually or use 'code $vscode_workspace_file' if VSCode is installed."
    fi
fi

echo "Project setup complete: $project_pwd/$projct_name"
cd "$initial_pwd" || {
    echo "🚫 Failed to return to $initial_pwd"
    exit 1
}

echo "✅ Done"
