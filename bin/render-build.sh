#!/usr/bin/env bash
# exit on error
set -o errexit

yarn install
bundle install
bundle exec rake db:migrate
