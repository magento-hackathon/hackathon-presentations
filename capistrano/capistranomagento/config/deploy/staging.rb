# STAGING-specific deployment configuration
# please put general deployment config in config/deploy.rb

### CUSTOM VARIABLE
set :http_domain, "staging.magehackathon.local"
set :location, http_domain

set :wwwuser, "sylvain"
set :wwwgroup, "root"
set :serverroot, "/mnt/hgfs/web/#{http_domain}"
set :www_root, "#{serverroot}/htdocs"

### CAPISTRINO SETUP
set :user, "sylvain" # SSH user
# set :scm_username, “foo”
# set :use_sudo, false
# set :ssh_options, { :forward_agent => true, :port: 22 }

## Here is a special configuration for git repo placed on your local machine and available also on the virtual machine
set :repository, "/mnt/hgfs/web/magehackathon/#{application}" # Git repo accessible from the virtual machine thanks to shared folder
set :local_repository, "./" # Git repo on the local machine where capistrano is executed. To comment in case repo is available from a remote server
# set :repository, "diglin@github.com/diglin/Diglin_Github.git" # Git remote repo for example
set :scm, :git # other version control system are also available: e.g. svn, mercurial,
set :branch, "master"

set :deploy_to, "#{serverroot}/capiroot/apps/#{application}"

role :web, location                         # Your web server domain or IP. e.g. Apache or nginx
role :app, location                         # This may be the same as your `Web` server
role :db,  location, :primary => true
# role :db, '192.123.123.123' # slave database for example

### MAGENTO WEB APPLICATION VARIABLE
set :install_date, "Sat, 03 Mar 2013 12:36:42 +0000"
set :install_key, "bb3a600aadf56789op2c5b6c91e69868"
set :session_save, "files"
set :admin_frontname, "admin"
set :db_init_statement, "SET NAMES UTF8"

set :http_protocol, "http"
set :http_secure_protocol, "https"
set :google_analytics, 0
set :secure_admin, 1
set :secure_frontend, 1
set :dev_mailer, "my_staging_email@localhost.com"
set :magentodemo, 1
set :jscsscompression, 0