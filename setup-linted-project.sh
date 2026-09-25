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
config_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/configs"
if [ ! -d "$config_dir" ]; then
    echo "🚫 Config directory not found: $config_dir"
    exit 1
fi

initial_pwd=$(pwd)
project_pwd="$HOME/z-tmp"
project_name="my_project"

read -p "🎨 Formatter: Prettier or Oxfmt? [p/O] " fmt_response
fmt_response=${fmt_response:-O}

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
if [[ ${fmt_response:0:1} =~ ^[Pp]$ ]]; then
    npm install --save-dev --save-exact \
        prettier \
        oxlint \
        postcss postcss-html \
        stylelint stylelint-config-html stylelint-config-recommended \
        stylelint-config-standard stylelint-config-alphabetical-order \
        stylelint-value-no-unknown-custom-properties stylelint-order
else
    npm install --save-dev --save-exact \
        oxfmt \
        oxlint \
        lint-staged \
        postcss postcss-html \
        stylelint stylelint-config-html stylelint-config-recommended \
        stylelint-config-standard stylelint-config-alphabetical-order \
        stylelint-value-no-unknown-custom-properties stylelint-order
fi

cp "$config_dir/oxlintrc.json" .oxlintrc.json
cp "$config_dir/.htmlhintrc" .htmlhintrc
cp "$config_dir/.stylelintrc.json" .stylelintrc.json
cp "$config_dir/css-starter.css" styles.css

if [[ ${fmt_response:0:1} =~ ^[Pp]$ ]]; then
    cp "$config_dir/.prettierrc" .prettierrc
else
    cp "$config_dir/.oxfmtrc.json" .oxfmtrc.json
fi

if [[ ! ${fmt_response:0:1} =~ ^[Pp]$ ]]; then
    npm pkg set scripts.format="oxfmt"
    npm pkg set scripts.format:check="oxfmt --check"
    jq '. + {"lint-staged": {"*": "oxfmt --no-error-on-unmatched-pattern"}}' package.json >temp.json && mv temp.json package.json
fi

if jq . .stylelintrc.json >/dev/null 2>&1; then
    jq '.rules["csstools/value-no-unknown-custom-properties"][1].importFrom = ["./styles.css"]' .stylelintrc.json >temp.json && mv temp.json .stylelintrc.json
else
    echo "Error: .stylelintrc.json is not valid JSON"
    exit 1
fi

git init

read -p "🐘 Include PHP config? [Y/n] " response
response=${response:-Y}

if [[ ${response:0:1} =~ ^[Yy]$ ]]; then
    cp "$config_dir/.php-cs-fixer.php" .php-cs-fixer.php
    cp "$config_dir/phpcs.xml" phpcs.xml
    cp "$config_dir/composer.json" composer.json

    # Formats the HTML in PHP templates (nvim runs html-beautify before php-cs-fixer)
    npm install --save-dev --save-exact js-beautify
    cat >.jsbeautifyrc <<'EOF'
{
  "html": {
    "templating": ["php"],
    "indent_size": 4,
    "indent_char": " ",
    "indent_inner_html": true,
    "extra_liners": [],
    "wrap_line_length": 100,
    "end_with_newline": true
  }
}
EOF

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
    cp "$config_dir/project.code-workspace" "$vscode_workspace_file"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$vscode_workspace_file" 2>/dev/null || echo "⚠️ Could not open VSCode workspace (macOS-specific command)"
    else
        echo "⚠️ 'open' command is macOS-specific. Please open $vscode_workspace_file manually or use 'code $vscode_workspace_file' if VSCode is installed."
    fi
fi

echo "Project setup complete: $project_pwd/$project_name"
cd "$initial_pwd" || {
    echo "🚫 Failed to return to $initial_pwd"
    exit 1
}

echo "✅ Done"
