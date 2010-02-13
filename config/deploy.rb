set :application, "astacus"
set :user,        "astacus"
set :password,    "astacus"
set :domain,      "vm-appserver"
set :repository,  "git@github.com:japgolly/astacus.git"
set :use_sudo,    false
set :deploy_to,   "/srv/#{application}"
set :scm,         "git"
set :branch,      "master"

# server "vm-appserver", :app, :web, :db, :primary => true
role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  desc "Start Application"
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  desc "Stop Application (not supported by Passenger)"
  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end

namespace :backgroundrb do
  desc "Start the backgroundrb server"
  task :start, :roles => :app do
    run "cd #{current_path} && nohup ruby script/backgroundrb start -e production </dev/null >/dev/null 2>&1"
  end

  desc "Stop the backgroundrb server"
  task :stop, :roles => :app do
    run "cd #{current_path} && ruby script/backgroundrb stop -e production"
  end

  desc "Check the status of the backgroundrb server"
  task :status, :roles => :app do
    run "cd #{current_path} && ruby script/backgroundrb status -e production"
  end

  desc "Start the backgroundrb server"
  task :restart, :roles => :app do
    stop
    start
  end
end

