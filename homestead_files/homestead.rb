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
