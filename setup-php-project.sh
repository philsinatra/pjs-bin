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
    @biomejs/biome \
    postcss postcss-html \
    stylelint stylelint-config-html stylelint-config-recommended \
    stylelint-config-standard stylelint-config-alphabetical-order \
    stylelint-value-no-unknown-custom-properties stylelint-order
npx @biomejs/biome init >/dev/null
curl -L https://gist.githubusercontent.com/philsinatra/910c20ec4d5ffb16ad97350839a6c664/raw/biome.json -o biome.json
curl -L https://gist.githubusercontent.com/philsinatra/3f1bd2e1cb2a4d4408318697400085fe/raw/.htmlhintrc -o .htmlhintrc
curl -L https://gist.githubusercontent.com/philsinatra/3f1bd2e1cb2a4d4408318697400085fe/raw/.stylelintrc.json -o .stylelintrc.json
curl -L https://gist.githubusercontent.com/philsinatra/79a52c69107d7fa899b88aea25f7f295/raw/css-starter.css -o public/assets/css/styles.css
curl -L https://gist.githubusercontent.com/philsinatra/3f1bd2e1cb2a4d4408318697400085fe/raw/.php-cs-fixer.php -o .php-cs-fixer.php
curl -L https://gist.githubusercontent.com/philsinatra/3f1bd2e1cb2a4d4408318697400085fe/raw/phpcs.xml -o phpcs.xml
curl -L https://gist.githubusercontent.com/philsinatra/3f1bd2e1cb2a4d4408318697400085fe/raw/composer.json -o composer.json

if jq . .stylelintrc.json >/dev/null 2>&1; then
    jq '.rules["csstools/value-no-unknown-custom-properties"][1].importFrom = ["./styles.css"]' .stylelintrc.json >temp.json && mv temp.json .stylelintrc.json""
else
    echo "Error: .stylelintrc.json is not valie JSON"
    exit 1
fi

git init

if ! command -v composer &>/dev/null; then
    echo "❌ Composer is not installed"
    echo "Visit https://getcomposer.org/download/ for installation instructions"
else
    composer install
fi

echo "Project setup complete: $project_pwd/$projct_name"

cd "$initial_pwd" || {
    echo "🚫 Failed to return to $initial_pwd"
    exit 1
}

echo "✅ Done"
