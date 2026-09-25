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
project_pwd="$HOME/Sites/localhost"
project_name="my_php_project"

if [ -d "$project_pwd/$project_name" ]; then
    echo "🚫 Project directory $project_pwd/$project_name already exists."
    exit 1
fi

mkdir -p "$project_pwd/$project_name"
cd "$project_pwd/$project_name" || {
    echo "🚫 Failed to change to $project_pwd/$project_name"
    exit 1
}

mkdir -p public src lib config storage
mkdir -p public/assets public/assets/css public/assets/js public/assets/images
mkdir -p src/Controllers src/Models src/Views src/Views/layouts src/Views/home src/Core
mkdir -p lib/components lib/utils lib/stores
mkdir -p storage/logs

touch public/index.php
touch src/Core/Application.php src/Core/Router.php src/Core/Controller.php
touch src/Controllers/HomeController.php
touch src/Models/Database.php
touch src/Views/layouts/main.php
touch src/Views/home/index.php
touch config/database.php config/app.php config/routes.php
touch .htaccess

npm init -y >/dev/null
npm install --save-dev --save-exact \
    oxlint prettier \
    js-beautify \
    postcss postcss-html \
    stylelint stylelint-config-html stylelint-config-recommended \
    stylelint-config-standard stylelint-config-alphabetical-order \
    stylelint-value-no-unknown-custom-properties stylelint-order

cp "$config_dir/oxlintrc.json" .oxlintrc.json
cp "$config_dir/.prettierrc" .prettierrc
cp "$config_dir/.htmlhintrc" .htmlhintrc
cp "$config_dir/.stylelintrc.json" .stylelintrc.json
cp "$config_dir/css-starter.css" public/assets/css/styles.css
cp "$config_dir/.php-cs-fixer.php" .php-cs-fixer.php
cp "$config_dir/phpcs.xml" phpcs.xml
cp "$config_dir/composer.json" composer.json

# Formats the HTML in PHP templates (nvim runs html-beautify before php-cs-fixer)
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

if jq . .stylelintrc.json >/dev/null 2>&1; then
    jq '.rules["csstools/value-no-unknown-custom-properties"][1].importFrom = ["./public/assets/css/styles.css"]' .stylelintrc.json >temp.json && mv temp.json .stylelintrc.json
else
    echo "Error: .stylelintrc.json is not valid JSON"
    exit 1
fi

git init

if ! command -v composer &>/dev/null; then
    echo "❌ Composer is not installed"
    echo "Visit https://getcomposer.org/download/ for installation instructions"
else
    composer install
fi

echo "Project setup complete: $project_pwd/$project_name"

cd "$initial_pwd" || {
    echo "🚫 Failed to return to $initial_pwd"
    exit 1
}

echo "✅ Done"
