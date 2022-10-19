#!/usr/bin/env bash
# exit on error
set -o errexit

curl --create-dirs -o $HOME/.postgresql/root.crt -O https://cockroachlabs.cloud/clusters/0e9cde74-b548-41f1-bdaa-f5fd25a65c6a/cert
yarn install
bundle install
# bundle exec rake assets:precompile
# bundle exec rake assets:clean
bundle exec rake db:migrate
bunlde exec rake db:seed
