set :application, "wuzlr"
set :user,        "wuzlr"
set :deploy_to,   "/home/#{user}/#{application}"
set :revision,    "master"
set :repository,  "git@github.com:kernow/wuzlr.git"
set :domain,      "#{user}@209.20.78.74"
set :rails_env,   "production"

namespace :vlad do

  # Rake.clear_tasks('vlad:start_app')  
  # desc 'Restart Passenger'
  # remote_task :start_app, :roles => :app do
  #   run "touch #{current_path}/tmp/restart.txt"
  # end
  
  desc "Install gems."
  remote_task :install_gems, :roles => :app do
    run "cd #{current_path}; #{rake_cmd} RAILS_ENV=#{rails_env} gems:install"
  end
  
  desc "Seed database."
  remote_task :seed, :roles => :app do
    run "cd #{current_path}; #{rake_cmd} RAILS_ENV=#{rails_env} db:seed"
  end
  
  remote_task :update, :roles => :app do
    Rake::Task['vlad:install_gems'].invoke
  end
  
  remote_task :git_revision do
    set :current_sha, run("cd #{File.join(scm_path, 'repo')}; git rev-parse origin/master").strip
  end
  
  task :git_user do
    set :current_user, `git config --get user.name`.strip
  end
  
  desc "Full deployment cycle"
  task :deploy => [:update, :migrate, :start_app]
end

