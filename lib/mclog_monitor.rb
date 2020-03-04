class MCLogMonitor
  LOG_FILE_PATH = Config::MINECRAFT[:monitored_log]

  def initialize
    @logfile = File.open(LOG_FILE_PATH, 'r')
  end

  def monitoring
    line = nil
    @logfile.seek(0, IO::SEEK_END)

    loop do
      new_line = @logfile.gets

      if (line != new_line)
        puts line = new_line
      end

      sleep 0.5
    end
  end
end
