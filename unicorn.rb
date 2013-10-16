worker_processes 3

#set root app
#ex. /usr/local/rails_apps/app/current
app_directory = "/usr/local/rails_apps/lab/current"
working_directory app_directory

#set port numuber or sock
#ex. 5000
listen PORT_NUMBER, :tcp_nopush => true

timeout 30

# set pid
#ex. /tmp/unicorn_app_name
pid "/tmp/unicorn_app.pid"

stdout_path "#{app_directory}/log/unicorn_production.log"

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{app_directory}/Gemfile"
end

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
  sleep 1
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
