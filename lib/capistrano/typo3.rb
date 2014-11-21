require "capistrano/typo3/version"
require 'yaml' # Built in, no gem required
load File.expand_path('../tasks/typo3.cap', __FILE__)
load File.expand_path('../tasks/deploy.cap', __FILE__)
load File.expand_path('../tasks/git.cap', __FILE__)
