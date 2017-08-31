server 'localhost', roles: %w{web}

set :stage, :production
set :deploy_to, 'DIR'
set :tmp_dir, "/tmp"
set :branch, "master"

set :dbname, 'test'
set :dbuser, 'root'
set :dbpass, ''
set :dbhost, 'localhost'

set :main_domain_name, 'localhost'
set :restart_webserver, "echo RESTART_APACHE_NOT_IMPLEMENTED"
set :t3_protocol, "http"
