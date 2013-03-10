load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['plugins/*/lib/recipes/*.rb'].each { |plugin| load(plugin) }
load Gem.find_files('mage.rb').last.to_s
load 'config/deploy'