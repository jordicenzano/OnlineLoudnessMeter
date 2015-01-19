cwd = File.expand_path(File.join(File.dirname(__FILE__), %w[ ./ ]))

config_path = File.join(cwd, %w{ config dj.yml } )

workers_count = if File.exists?(config_path)
  YAML.load_file(config_path).try(:[], "workers") || 1
else
  1
end

#Create PIDS dir if does not exists
tmp_path = File.join(cwd, %w{ tmp } )
if (!Dir.exists?(tmp_path))
  Dir.mkdir(tmp_path)
end
pids_path = File.join(cwd, %w{ tmp pids } )
if (!Dir.exists?(pids_path))
  Dir.mkdir(pids_path)
end

Eye.application 'delayed_job' do
  env 'RAILS_ENV' => 'production'
  working_dir cwd
  stop_on_delete true

  stdall 'trash.log' # stdout,err logs for processes by default

  #trigger :flapping, times: 10, within: 1.minute, retry_in: 10.minutes
  check :cpu, every: 10.seconds, below: 100, times: 3 # global check for all processes

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