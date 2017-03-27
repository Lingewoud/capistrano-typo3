#!/bin/sh

# Check tools

bundle init
echo "gem 'capistrano-typo3', :git =>'https://github.com/Lingewoud/capistrano-typo3.git'" >> Gemfile
bundle install --binstubs --path vendor

./bin/cap install STAGES=homestead,staging,live


echo "require 'capistrano/typo3'" >> Capfile
