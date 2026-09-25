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
project_name="my_svelte_project"

if [ -d "$project_pwd/$project_name" ]; then
    echo "🚫 Project directory $project_pwd/$project_name already exists."
    exit 1
fi

mkdir -p "$project_pwd"
cd "$project_pwd" || {
    echo "🚫 Failed to change to $project_pwd"
    exit 1
}

npx sv create "$project_name"

cd "$project_name" || {
    echo "🚫 Failed to change to $project_pwd/$project_name"
    exit 1
}

npm install --save-dev --save-exact \
    postcss postcss-html \
    stylelint stylelint-config-html stylelint-config-recommended \
    stylelint-config-standard stylelint-config-alphabetical-order \
    stylelint-value-no-unknown-custom-properties stylelint-order

cp "$config_dir/.htmlhintrc" .htmlhintrc
cp "$config_dir/.stylelintrc.json" .stylelintrc.json
cp "$config_dir/css-starter.css" ./src/lib/screen.css

git init

if jq . .stylelintrc.json >/dev/null 2>&1; then
    jq '.rules["csstools/value-no-unknown-custom-properties"][1].importFrom = ["./src/lib/screen.css"]' .stylelintrc.json >temp.json && mv temp.json .stylelintrc.json
else
    echo "Error: .stylelintrc.json is not valid JSON"
    exit 1
fi

echo "Project setup complete: $project_pwd/$project_name"

cd "$initial_pwd" || {
    echo "🚫 Failed to return to $initial_pwd"
    exit 1
}

echo "✅ Done"
