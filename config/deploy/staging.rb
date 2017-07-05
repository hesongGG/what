role :app, %w{www@120.26.201.136}
role :web, %w{www@120.26.201.136}
role :db, %w{www@120.26.201.136}
role :worker, %w{www@120.26.201.136}

set :deploy_to, "/var/www/mis_staging"
set :html_deploy_to, "#{fetch(:deploy_to)}/html"

set :rvm_type, :system
set :rvm_ruby_version, '2.2.3'
set :rvm_custom_path, '/home/www/.rvm'

#set :nginx_sites_enabled_path, "#{shared_path}/config"
#set :nginx_sites_available_path, "#{shared_path}/config"
set :nginx_server_name, "xyz.test.com"
set :puma_init_active_record, false
set :puma_workers, 2

set :rails_env, "staging"

#set :branch, 'staging'
set :html_branch, 'development'

set :sidekiq_role, :worker
set :monit_role, :all
