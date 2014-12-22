set :stage, :production

server '54.194.190.14', user: 'deploy', roles: %w{web app}
