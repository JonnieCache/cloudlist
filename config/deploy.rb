set :application, "cloudlist"
set :deploy_to, "/var/srv/sinatra/#{application}"

set :repository, "file:///var/srv/git/cloudlist.git"
set :local_repository,  "ssh://jonnie@cleverna.me:18512/var/srv/git/cloudlist.git"

set :user, 'jonnie'
set :use_sudo, false
set :port, 18512

set :scm, :git
set :branch, 'master'
set :git_shallow_clone, 1

set :server_name, 'cloudlist.cleverna.me'

role :web, server_name
role :app, server_name
role :db,  server_name, :primary => true


namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end