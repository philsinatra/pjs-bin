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
project_name="my_svelte_project"

if [ -d "$project_pwd/$project_name" ]; then
    echo "🚫 Project directory $project_pwd/$project_name already exists."
    exit 1
fi

cd $project_pwd

npx sv create $project_name

cd $project_name

npm install --save-dev --save-exact \
    postcss postcss-html \
    stylelint stylelint-config-html stylelint-config-recommended \
    stylelint-config-standard stylelint-config-alphabetical-order \
    stylelint-value-no-unknown-custom-properties stylelint-order

curl -L https://gist.githubusercontent.com/philsinatra/3f1bd2e1cb2a4d4408318697400085fe/raw/.htmlhintrc -o .htmlhintrc
curl -L https://gist.githubusercontent.com/philsinatra/3f1bd2e1cb2a4d4408318697400085fe/raw/.stylelintrc.json -o .stylelintrc.json
curl -L https://gist.githubusercontent.com/philsinatra/79a52c69107d7fa899b88aea25f7f295/raw/css-starter.css -o ./src/lib/screen.css

git init

if jq . .stylelintrc.json >/dev/null 2>&1; then
    jq '.rules["csstools/value-no-unknown-custom-properties"][1].importFrom = ["./src/lib/screen.css"]' .stylelintrc.json >temp.json && mv temp.json .stylelintrc.json""
else
    echo "Error: .stylelintrc.json is not valie JSON"
    exit 1
fi

echo "Project setup complete: $project_pwd/$projct_name"

cd "$initial_pwd" || {
    echo "🚫 Failed to return to $initial_pwd"
    exit 1
}

echo "✅ Done"
