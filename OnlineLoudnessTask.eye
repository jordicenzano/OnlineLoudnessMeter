cwd = File.expand_path(File.join(File.dirname(__FILE__), %w[ ./ ]))

config_path = File.join(cwd, %w{ config dj.yml } )

workers_count = if File.exists?(config_path)
  YAML.load_file(config_path).try(:[], "workers") || 1
else
  1
end

Eye.application 'delayed_job' do
  working_dir cwd
  stop_on_delete true

  group 'dj' do
    chain grace: 10.seconds

    (1 .. workers_count).each do |i|
      process "dj-#{i}" do
        pid_file "tmp/pids/delayed_job.#{i}.pid"
        start_command "bundle exec rake onlineloudnesscalc:calcloudness"
        stdall "log/dj-#{i}.log"

        stop_command 'kill {PID}'

        daemonize true

        checks :cpu, :every => 5.seconds, :below => 30, :times => 5
        checks :memory, :every => 6.seconds, :below => 300.megabytes, :times => 5

        stop_signals [:INT, 30.seconds, :TERM, 10.seconds, :KILL]
      end
    end
  end
end