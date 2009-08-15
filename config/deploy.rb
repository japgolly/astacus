set :application, "astacus"
set :user,        "astacus"
set :password,    "astacus"
set :domain,      "vm-appserver"
set :repository,  "ssh://#{domain}/mnt/dropbox/projects/#{application}.git"
set :use_sudo,    false
set :deploy_to,   "/srv/#{application}"
set :scm,         "git"
set :branch,      "master"

# server "vm-appserver", :app, :web, :db, :primary => true
role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  # For deploying a database.yml file.
  #task :after_update_code, :roles => :app do
  #  run "ln -nfs #{deploy_to}/shared/system/database.yml #{release_path}/config/database.yml"
  #end
end

