require "capistrano/typo3/version"
require "capistrano/typo3/typo3_helper"
require "capistrano/typo3/dt3_div"
#require "capistrano/typo3/dt3_logger"
require "capistrano/typo3/dt3_mysql"
require 'yaml' # Built in, no gem required

load File.expand_path('../tasks/typo3.cap', __FILE__)
load File.expand_path('../tasks/deploy.cap', __FILE__)
load File.expand_path('../tasks/git.cap', __FILE__)



