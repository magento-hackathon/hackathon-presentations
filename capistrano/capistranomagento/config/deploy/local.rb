# LOCAL-specific deployment configuration
# please put general deployment config in config/deploy.rb

### CUSTOM VARIABLE
set :http_domain, "dev.magehackathon.local"
set :location, "127.0.0.1"

set :wwwuser, "sylvain"
set :wwwgroup, "www"
set :serverroot, "/mnt/hgfs/web/#{http_domain}"
set :www_root, "#{serverroot}/htdocs"

### CAPISTRINO SETUP
set :user, "sylvain" # SSH user
set :scm, :none # other version control system are also available: e.g. svn, mercurial,

## For local deployment, we set the path to current path
set :deploy_to, "."
set :release_path, "."
set :current_path, "."
set :shared_path, "."

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

## Overwritten tasks cause of local deployment
# run all commands locally
def run(cmd)
    #logger.trace "executing locally: #{cmd.inspect}" if logger
    run_locally cmd
    #    puts `#{cmd}`
end

def sudo(cmd)
    run(cmd)
end

def remote_file_exists(full_path)
    File.exists?(full_path)
end

def upload (source, target)
    run "cp #{source} #{target}"
end

desc "override deployment task with void actions for local development stage"
namespace :deploy do
    task :check do
    end
    
    task :update_code do
        
    end
    
    task :update do
        
    end
    
    task :create_symlink do
        
    end
    
    task :deploy do
    end
end