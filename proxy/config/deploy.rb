set :application, "iSquid3"
set :repository,  "file://#{File.expand_path('.')}"

set :domain, "iskander.bgpu.ru"
set :user, "root"

server "#{domain}", :app, :web, :db, :primary => true

set :deploy_via, :copy
set :copy_exclude, [".git", ".DS_Store", "Capfile"]
set :scm, :git
set :branch, "master"

set :deploy_to, "/opt/squid/conf"
set :use_sudo, false
set :keep_releases, 5
set :git_shallow_clone, 1
ssh_options[:paranoid] = false

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
namespace :deploy do

  desc "Update config files and create the symlink"
  task :default do
    transaction do
      update_code
      create_symlink
      run "/opt/squid/sbin/squid -k parse"
      run "/opt/squid/sbin/squid -k reconfigure"
    end
  end

  task :update_code, :except => { :no_release => true } do
    on_rollback { run "rm -rf #{release_path}; true" }
    strategy.deploy!
  end

  task :after_deploy do
    cleanup
  end

end