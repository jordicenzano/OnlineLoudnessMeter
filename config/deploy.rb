# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'OnlineLoudnessMeter'
set :repo_url, 'git@github.com:jordicenzano/OnlineLoudnessMeter.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/deploy/OnlineLoudnessMeter'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc 'Stop worker processes (eye)'
  task :stopworker do
    on roles(:app), in: :sequence, wait: 5 do
      execute "export PATH='$PATH:$HOME/.rvm/bin'; source ~/.rvm/scripts/rvm; cd #{deploy_to}/current; ~/.rvm/bin/rvm use ruby-2.1.3; eye stop delayed_job; true"
      execute "cd #{deploy_to}/current; ./bin/eye quit; true"
    end
  end

  desc 'Start worker processes (eye)'
  task :startworker do
    on roles(:app), in: :sequence, wait: 5 do
      execute "cd #{deploy_to}/current; eye load #{release_path.join('OnlineLoudnessTask.eye')}"
      execute "cd #{deploy_to}/current; eye start delayed_job"
    end
  end

  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'

  before :starting, 'deploy:stopworker'
  after :finishing, 'deploy:startworker'
end
