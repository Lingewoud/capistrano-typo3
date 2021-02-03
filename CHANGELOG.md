# CHANGELOG


## capistrano-typo3 0.5.5
- restore passwordless sync for local syncs e.g. CCV certificatie

## capistrano-typo3 0.5.4
- make git recursive optional

## capistrano-typo3 0.3.2
- make mysql dump transfer possible on same server with different users

## capistrano-typo3 0.3.2
- hotfix wrong additional path

## capistrano-typo3 0.3.1
- split mysql sync commands into sep. commands to prevent site locking
- add trusted hosts to homestead

## capistrano-typo3 0.2.4 2015-03-09
- add clear all cache task

## capistrano-typo3 0.2.3 2015-02-18
- update dependencies

## capistrano-typo3 0.2.2
- always use use ./bin/rake
- always flush content cache after sync
- always set stage in before hooks
- renamed and implemented keep_git, now named git_no_cache
- large refactor
- reimplement typo3_conf_vars (TYPO3 6.x supported only)
- more cmd aliases for more compatibility (Now supporting OSX Yosemite)
- add create yml to info task
- add pull to info task
- add capistrano dependency
- add run sql updated after migrations
- fix wrong pp requirement
- removal of breaking debugging code
- only write yaml when conf arr is available
- bundle_executable config var

## capistrano-typo3 0.2.1
* new init tasks and rename setup to init
* code cleanup
* use new rake-typo3 repository in place of deployTYPO3

## capistrano-typo3 0.2.0
* new official name: capistrano-typo3
* publishing to rubygems
* add typo3 db migrations
* add pre and post tests
* update src after deploy
* Removed Manual, for now use README.md

## captypo3 0.1.6
* add db migrate
* add always pull deployTYPO3
* add rspec task

## captypo3 0.1.5
* add sync & deploy for continuous integration
* add content cache flush
* initial 6.x compatibility
* add stock gitignore
* update manual
	* add upgrade section howto
* remove double upgrade task

## captypo3 0.1.4
* new name captypo3
* new task git:pending
* new task git:pending_since[hash]
* new task deploy:last_revision

## typo3capistrano 0.1.3

* new tasks setup_fase1
* new tasks setup_fase2
* new tasks setup_fase3
* update Manual.md
* lots of fixes

## typo3capistrano 0.1.2
* rename GEM

## cap3typo3 0.1.1
* complete rewrite, let deployTYPO3 do all the work, lean and mean

