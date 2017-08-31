#!/bin/sh

# Check tools

bundle init
echo "gem 'capistrano-typo3', :git =>'https://github.com/Lingewoud/capistrano-typo3.git'" >> Gemfile
echo "gem 'capistrano-locally'"

bundle install --binstubs --path vendor

./bin/cap install STAGES=staging,live

echo "require 'capistrano/typo3'" >> Capfile
echo "require 'capistrano/locally'" >> Capfile
