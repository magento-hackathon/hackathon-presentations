require 'capistrano/ext/multistage'

set :stages, %w(local production staging)
set :default_stage, "local"

### CAPISTRINO SETUP
default_run_options[:pty] = true

set :application, "capistranomagento"
set :keep_releases,  5

set :deploy_via, :remote_cache # possible values: copy, checkout, remote_cache, export

### Magentify specific variables
set :app_symlinks, ["/media", "/var"]
set :app_shared_dirs, ["/app/etc", "/media", "/var"]
set :app_shared_files, ["/app/etc/local.xml"]

## Methods
def get_yamldbconfig()
    return YAML::load_file( File.dirname(__FILE__)  + "/database.yml")
end

def remote_file_exists(full_path)
    'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

### CUSTOM TASKS
namespace :tools do
    desc "Clean unused files or folder of the current deployed release"
    task :cleanup, :roles => :web do
        run ("rm -rf #{current_release}/Capfile #{current_release}/config #{current_release}/RELEASE_NOTES.txt #{current_release}/php.ini.sample #{current_release}/.htaccess.sample #{current_release}/index.php.sample")
    end
    
    desc "Create database depending on your configuration"
    task :DBsetup, :roles => :db do
        yaml = get_yamldbconfig
        
        dbusername = yaml["#{stage}"]["dbuser"]
        dbpassword = yaml["#{stage}"]["dbpass"]
        dbname = yaml["#{stage}"]["dbname"]
        dbhost = yaml["#{stage}"]["dbhost"]
        
        run "mysql -u #{dbusername} -p#{dbpassword} -e \"DROP DATABASE IF EXISTS #{dbname}; CREATE DATABASE #{dbname} CHARACTER SET UTF8 COLLATE utf8_general_ci; GRANT ALL ON #{dbname}.* TO '#{dbusername}'@'localhost' identified by '#{dbpassword}';flush privileges;\""
    end
end

namespace :hackathon do
    desc "Create or update the local.xml file of Magento"
    task :fix_file_config, :roles => :web do
        yaml = get_yamldbconfig
        
        dbprefix = yaml["#{stage}"]["dbprefix"]
        dbhost = yaml["#{stage}"]["dbhost"]
        dbname = yaml["#{stage}"]["dbname"]
        dbusername = yaml["#{stage}"]["dbuser"]
        dbpassword = yaml["#{stage}"]["dbpass"]
        dbtype = yaml["#{stage}"]["dbtype"]
        dbmodel = yaml["#{stage}"]["dbmodel"]
        dbpdotype = yaml["#{stage}"]["dbpdotype"]
        
        # copy magento config template
        run "cp #{current_path}/app/etc/local.xml.template #{shared_path}/app/etc/local.xml"
        
        # search and replace with db settings
        run "sed -i \
        -e 's/{{date}}/<![CDATA[#{install_date}]]>/g' \
        -e 's/{{key}}/<![CDATA[#{install_key}]]>/g' \
        -e 's/{{db_host}}/<![CDATA[#{dbhost}]]>/g' \
        -e 's/{{db_prefix}}/<![CDATA[#{dbprefix}]]>/g' \
        -e 's/{{db_name}}/<![CDATA[#{dbname}]]>/g' \
        -e 's/{{db_user}}/<![CDATA[#{dbusername}]]>/g' \
        -e 's/{{db_pass}}/<![CDATA[#{dbpassword}]]>/g' \
        -e 's/{{db_init_statemants}}/<![CDATA[#{db_init_statement}]]>/g' \
        -e 's/{{db_model}}/<![CDATA[#{dbmodel}]]>/g' \
        -e 's/{{db_type}}/<![CDATA[#{dbtype}]]>/g' \
        -e 's/{{db_pdo_type}}/<![CDATA[#{dbpdotype}]]>/g' \
        -e 's/{{session_save}}/<![CDATA[#{session_save}]]>/g' \
        -e 's/{{admin_frontname}}/<![CDATA[#{admin_frontname}]]>/g' \
        #{shared_path}/app/etc/local.xml"
    end
    
    desc "Change the configuration of the Magento database to reflect deployment properties"
    task :fix_db_config, :roles => :db do
        yaml = get_yamldbconfig
        
        dbprefix = yaml["#{stage}"]["dbprefix"]
        dbhost = yaml["#{stage}"]["dbhost"]
        dbname = yaml["#{stage}"]["dbname"]
        dbusername = yaml["#{stage}"]["dbuser"]
        dbpassword = yaml["#{stage}"]["dbpass"]

        transaction do
            run "mysql -u #{dbusername} -p#{dbpassword} #{dbname} -e \" \
              replace into #{dbprefix}core_config_data set path='web/cookie/cookie_domain', value='#{http_domain}'; \
              replace into #{dbprefix}core_config_data set path='web/unsecure/base_url', value='#{http_protocol}://#{http_domain}/#{application}/'; \
              replace into #{dbprefix}core_config_data set path='web/secure/base_url', value='#{http_secure_protocol}://#{http_domain}/#{application}/'; \
              replace into #{dbprefix}core_config_data set path='google/analytics/active', value='#{google_analytics}'; \
              replace into #{dbprefix}core_config_data set path='web/secure/use_in_adminhtml', value='#{secure_admin}'; \
              replace into #{dbprefix}core_config_data set path='web/secure/use_in_frontend', value='#{secure_frontend}'; \
              replace into #{dbprefix}core_config_data set path='trans_email/ident_support/email', value='#{dev_mailer}'; \
              replace into #{dbprefix}core_config_data set path='design/head/demonotice', value='#{magentodemo}'; \
              replace into #{dbprefix}core_config_data set path='dev/js/merge_files', value='#{jscsscompression}'; \
              replace into #{dbprefix}core_config_data set path='dev/css/merge_css_files', value='#{jscsscompression}';\""
        end
    end
    
    desc "Import sample data with specific information to database. Executed after deploy:setup"
    task :import_sample_data, :roles => [:db], :only => { :primary => true } do # Here we suppose that web and db role are on the same server. Need to be improved if you have the db separate from the web
        yaml = get_yamldbconfig
        
        dbprefix = yaml["#{stage}"]["dbprefix"]
        dbhost = yaml["#{stage}"]["dbhost"]
        dbname = yaml["#{stage}"]["dbname"]
        dbusername = yaml["#{stage}"]["dbuser"]
        dbpassword = yaml["#{stage}"]["dbpass"]
        
        samplesqlfile = "magento_sample_data_for_1.6.1.0.sql"
        localsamplesqlfile = File.dirname(__FILE__)  + "/../shell/#{samplesqlfile}"
        
        abort  "#{localsamplesqlfile} doesnt exist locally" unless File.exists?( localsamplesqlfile)
        if !remote_file_exists("#{shared_path}/shell/#{samplesqlfile}") then
            run "mkdir -p #{shared_path}/shell"
            upload localsamplesqlfile, "#{shared_path}/shell/#{samplesqlfile}"
        end
        
        transaction do
            run "mysql -u #{dbusername} -p#{dbpassword} #{dbname} < #{shared_path}/shell/#{samplesqlfile}"
        end
    end
end

### CUSTOM HOOKS
after "deploy:setup", "tools:DBsetup"
after "deploy:create_symlink", "tools:cleanup", "hackathon:fix_file_config", "hackathon:fix_db_config"
after "tools:DBsetup", "hackathon:import_sample_data", "hackathon:fix_db_config", "hackathon:fix_file_config"

# after all files and permissions are in place update link to htdocs
after "deploy:create_symlink", :roles => :web do
    run "if [ -e #{www_root}/#{application} ]; then rm -rf #{www_root}/#{application}; fi"
    run "ln -sf #{current_path}/ #{www_root}/#{application}"
    run "chown -R #{wwwuser}:#{wwwgroup} #{www_root}/#{application}"
end
