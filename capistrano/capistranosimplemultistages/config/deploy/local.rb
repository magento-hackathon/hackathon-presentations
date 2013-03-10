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

### WEB APPLICATION VARIABLE
set :text, "<h1>This is a <strong>LOCAL</strong> demo!!!!</h1>"

### HOOK for this stage
after "deploy:update_code", :roles => :web do
    #run "awk '{gsub(\"placeholder_text\", \"#{text}\", $0); print $0 > FILENAME}' #{release_path}/index.php"
end


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