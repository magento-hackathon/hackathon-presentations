#require 'capistrano/ext/multistage'

### CUSTOM VARIABLE
set :location, 'production.magehackathon.local'
set :http_domain, location

set :wwwuser, "sylvain"
set :wwwgroup, "root"
set :serverroot, "/mnt/hgfs/web/#{http_domain}"
set :www_root, "#{serverroot}/htdocs"

### CAPISTRINO SETUP
set :user, "sylvain" # SSH user
# set :scm_username, “foo”
# set :use_sudo, false
# set :ssh_options, { :forward_agent => true, :port: 22 }
default_run_options[:pty] = true

set :application, "capistranosimple"
set  :keep_releases,  5

## Here is a special configuration for git repo placed on your local machine and available also on the virtual machine
set :repository, "/mnt/hgfs/web/magehackathon/#{application}" # Git repo accessible from the virtual machine thanks to shared folder
set :local_repository, "./" # Git repo on the local machine where capistrano is executed. To comment in case repo is available from a remote server
# set :repository, "diglin@github.com/diglin/Diglin_Github.git" # Git remote repo for example
set :scm, :git # other version control system are also available: e.g. svn, mercurial,
set :branch, "master"

set :deploy_via, :remote_cache # possible values: copy, checkout, remote_cache, export

set :deploy_to, "#{serverroot}/capiroot/apps/#{application}"

role :web, location                         # Your web server domain or IP. e.g. Apache or nginx
role :app, location                         # This may be the same as your `Web` server
role :db,  location, :primary => true
# role :db, '192.123.123.123' # slave database for example

### CUSTOM TASKS
namespace :tools do
    desc "Clean unused files or folder of the current deployed release"
    task :cleanup, :roles => :web do
        run ("rm -rf #{current_release}/Capfile #{current_release}/config")
    end
end

### CUSTOM HOOKS
after "deploy:setup", :roles => :web do
    run "if [ -e #{www_root} ]; then mkdir -p #{www_root}; fi"
end
after "deploy:update_code", "tools:cleanup"

# after all files and permissions are in place update link to htdocs
after "deploy:create_symlink", :roles => :web do
    run "if [ -e #{www_root}/#{application} ]; then rm -rf #{www_root}/#{application}; fi"
    run "ln -sf #{current_path}/ #{www_root}/#{application}"
    run "chown -R #{wwwuser}:#{wwwgroup} #{www_root}/#{application}"
end

### NON RAILS TASKS TO OVERWRITE
namespace :deploy do

  desc <<-DESC
    [Overload] Deploys your project. This calls "update". Note that \
    this will generally only work for applications that have already been deployed \
    once. For a "cold" deploy, you\'ll want to take a look at the "deploy:cold" \
    task, which handles the cold start specifically.
  DESC
  task :default do
    update
  end

  desc <<-DESC
    [Overload] Touches up the released code. This is called by update_code \
    after the basic deploy finishes.

    This method should be overridden to meet the requirements of your allocation.
  DESC
  task :finalize_update, :except => { :no_release => true } do
    # do nothing for non rails apps
  end

  desc <<-DESC
    [Overload] Default actions cancelled
  DESC
  task :restart, :roles => :app, :except => { :no_release => true } do
    # do nothing for non rails apps
  end

  desc <<-DESC
    [Overload] Default actions cancelled.
  DESC
  task :migrate, :roles => :db, :only => { :primary => true } do
    # do nothing for non rails apps
  end

  desc <<-DESC
    [Overload] Default actions cancelled.
  DESC
  task :migrations do
    set :migrate_target, :latest
    # // do nothing for non rails apps
  end

  desc <<-DESC
    [Overload] Default actions only calls "update".
  DESC
  task :cold do
    update
  end
  
  desc <<-DESC
    [Overload] Default actions cancelled.
  DESC
  task :restart do
  end

  desc <<-DESC
    [Overload] Default actions cancelled.
  DESC
  task :start do
  end

  desc <<-DESC
    [Overload] Default actions cancelled.
  DESC
  task :stop do
  end
end
