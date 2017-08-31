# Nieuwe site

Dit is een verslag van een from scratch installatie, dat moet leiden tot
een complete handleiding.

verslag TYPO3 omgeving maken voor development en release

# TODO

- Gemfile
- Bundle install --bincaps
- Capfile
- Dir str.
- testing
- prelive
- homestead conf
- Dummy dir met typo3 vanilla
- TYPO3 installatie

### Stap 1 gitrepogemaakt en gecloned om in te werken

### Stap 2 prelive omgeving

Deze omgeving dient als content master zolang de website niet gereleased
is. Om die reden maken we deze omgeving als eerste aan zodat de test en
homestead omgeving gesynced kan worden met deze omgeving.

- omgeving prelive op webserver met webpad,

htdocroot =

```
/var/customers/webs/userdev/point-prelive/current/dummy
```

- database

### Stap 3
in repo working copy

vim Gemfile

```
source 'https://rubygems.org'
gem 'capistrano', '~> 3.5.0'
gem 'capistrano-typo3', :git =>'https://github.com/mipmip/capistrano-typo3.git'
```

```
bundle install --binstubs
```

```
cap install STAGES=homestead,staging,live
```

Voeg toe aan Capfile

```
require 'capistrano/typo3'
```



### Stap 4

in repo working copy

```
mkdir -p config/deploy/
```

vim config/deploy/prelive.rb

pas aan met instellingen zoals: 

```
server 'xxxxx.xxxxxx.net', roles: %w{web}, port: 22

set :user, 'userxxx'

set :deploy_to, "/var/www/#{fetch(:user)}/point-prelive"
set :tmp_dir, "/var/www/#{fetch(:user)}/tmp"
set :ssh_options, { user: fetch(:user) }

set :stage, :prelive
set :http_protocol, 'http'
set :branch, "master"
set :t3_dont_upgrade_source, 1

set :main_domain_name, 'xxxxx.net'

set :dbname, 'dbxxx'
set :dbuser, 'userxxx'
set :dbpass, 'xxxxxx'
set :dbhost, 'localhost'
```

and config/deploy.rb

```
set :application, 'point-env001-t3'

set :repo_url, 'git@gitlab.lingewoud.net:HS-TYPO3/point-env001-t3.git'

set :scm, :git
set :log_level, :debug
set :keep_releases, 5

set :domain_org, 'point-prelive.dev2.lingewoud.net'

set :t3_main_version, '7.6'
```

### Stap 5, download typo3

```
mkdir dummy
cd dummy
cd tar xzvf ~/Downloads/typo3_src-7.6.11.tar.gz
ln -s typo3_src/index.php
ln -s typo3_src/typo3
cp typo3_src/_.htaccess .htaccess
```

commit and push


### Stap 6, remote setup

```
typo3:helper:rm_deploy_to
deploy
typo3:helper:setup_shared_typo3_dirs
typo3:helper:current_relative_symlink
first_install
```


### Stap 7, maak in de browser de installatie van prelive af

Haal daarna dummy/typo3conf/ naar local for import in git
```
rsync -av userdev@volkert.node.lingewoud.net:/var/customers/webs/userdev/point-prelive/current/dummy/typo3conf/ dummy/typo3conf/
git add dummy
git commit dummy
git push
```

### Stap 8, maak test-env klaar


maak configuratie van test in orde

```

```

commit en push alles weg

```
git checkout -b developer
git push --set-upstream origin developer
```

maak in deploy.rb de sync in orde

```
set :t3_live_sync, -> do
  {
    'filesync' => {
      'fileadmin' => 'rsync -av xxxx@xxxx.net:/var/www/xxxx-prelive/shared/fileadmin/  shared/fileadmin/',
      'uploads' => 'rsync -av xxxx@xxxx.net:/var/www/xxxx-prelive/shared/uploads/  shared/uploads/',
    },
    'dbsync' => {
      'ssh_server' => 'xxxx.net',
      'ssh_user' => 'userdev',
      'dbname' => 'xxxx',
      'dbuser' => 'xxxx',
      'dbpass' => 'xxxx',
      'dbhost' => 'xxxx',
    },
  }
end

set :t3_sql_updates, -> do
  [
#    "UPDATE sys_template SET constants = REPLACE(constants, 'http://www.#{fetch(:domain_org)}/','http://#{fetch(:main_domain_name)}/') where uid=1",
#    "UPDATE sys_domain SET domainName = '#{fetch(:main_domain_name)}' WHERE uid = 1",
#    "DELETE FROM sys_domain WHERE uid = 1",
  ]
end
```


### Stap 9 vagrant machine

maak homestead conf.

```
server 'localhost', roles: %w{web allow_syncfiles allow_syncdatabase}, port: 2222
set :user, 'vagrant'
set :stage, :homestead
set :deploy_to, '/var'
set :ssh_options, { user: 'vagrant', port: 2222, keys: ['.vagrant/machines/default/virtualbox/private_key'] }
set :tmp_dir, "/tmp"
set :bundle_executable, "/usr/local/bin/bundle"
set :restart_webserver, "sudo service nginx restart"

set :branch, "developer"

set :git_no_cache, 1

set :t3_store_db_credentials_in_addionalconf, 1
set :t3_add_unsafe_trusted_host_pattern, 1
set :t3_dont_upgrade_source, 1

set :hs_default_upstream_php_engine, 'php56'

set :main_domain_name, 'local.typo3.org'
set :dbname, 'captypo3homestead'
set :dbuser, 'root'
set :dbpass, 'supersecret'
set :dbhost, 'localhost'

sync_ignore_items = [
#  '*.pdf'
]
sync_ignore = ''
  sync_ignore_items.each do | ignore_item |
  sync_ignore << "--exclude '#{ignore_item}' "
end

set :t3_rsync_ignore, sync_ignore
set :t3_protocol, "http"
```


### Stap 10 Setup machine


installeer de juiste vagrant.yml en Vagrantfile


```
./bin/cap homestead  typo3:vagrant:setup_machine
```


### Stap 20 Setup gitlab-ci.yml

set key in variablen van gitlab

keynaam: SSH_PRIVATE_KEY
kay waarde: een key die met test en prelive ssh mag connecten

### Stap xxx Maak backend test gebruiker met nieuwe ww:

automated_test web->page

### voeg minitest en watir toe
