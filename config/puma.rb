# Change to match your CPU core count
# You can check available worker numbers with $ grep -c processor /proc/cpuinfo
# also see the comment in the nginx.conf
workers 4 

# Min and Max threads per worker
#threads 1, 6

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

# Set up socket location
bind "unix://#{shared_dir}/puma.sock"

# Logging
#stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/puma.pid"
state_path "#{shared_dir}/puma.state"
#activate_control_app

#on_worker_boot do
#  require "active_record"
#  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
#  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
#end
