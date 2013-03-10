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

### WEB APPLICATION VARIABLE
set :text, "<h1>This is a <strong>STAGING</strong> demo!!!!</h1>"

### HOOK for this stage
after "deploy:update_code", :roles => :web do
    run "awk '{gsub(\"placeholder_text\", \"#{text}\", $0); print $0 > FILENAME}' #{release_path}/index.php"
end