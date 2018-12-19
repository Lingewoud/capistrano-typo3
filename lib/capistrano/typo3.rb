require 'securerandom'

require "capistrano/typo3/version"
require "capistrano/typo3/typo3_helper"
require "capistrano/typo3/dt3_div"
require "capistrano/typo3/dt3_mysql"
require 'yaml' # Built in, no gem required

TYPO3_DB_DUMP_DIR = 'db_dumps'

load File.expand_path('../tasks/typo3.cap', __FILE__)
load File.expand_path('../tasks/typo3content.cap', __FILE__)
load File.expand_path('../tasks/typo3helper.cap', __FILE__)
load File.expand_path('../tasks/typo3util.cap', __FILE__)
load File.expand_path('../tasks/typo3homestead.cap', __FILE__)
load File.expand_path('../tasks/typo3test.cap', __FILE__)
load File.expand_path('../tasks/typo3vagrant.cap', __FILE__)

load File.expand_path('../tasks/wp_homestead.cap', __FILE__)

load File.expand_path('../tasks/deploy.cap', __FILE__)
load File.expand_path('../tasks/git.cap', __FILE__)
load File.expand_path('../tasks/db.cap', __FILE__)
load File.expand_path('../tasks/sync.cap', __FILE__)



