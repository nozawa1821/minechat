class MCLogMonitor
  LOG_FILE_PATH = Config::MINECRAFT[:monitored_log]

  def initialize(discord_bot)
    @logfile = File.open(LOG_FILE_PATH, 'r')
    @discord_bot = discord_bot
  end

  def monitoring
    line = nil
    @logfile.seek(0, IO::SEEK_END)

    loop do
      new_line = @logfile.gets

      if (line != new_line)
        send_log(convert_message(new_line))
        line = new_line
      end

      sleep 0.5
    end
  end

  def send_log(message)
    return if message == nil

    @discord_bot.send_message(668682153583837185, message)
    puts "discordにログを送信しました：#{message}"
  end

  def convert_message(log)
    return nil if log == nil


    # rconに関するログを排除
    rcon_message = '\[\d+:\d+:\d+\] \[.+\]: \[Rcon\] (.+)'
    rcon_info = '^\[\d+:\d+:\d+\] \[.+\]: Rcon .+$'
    return nil if log.match(rcon_message) || log.match(rcon_info)

    # chatメッセージの場合は整形する
    message_legexp = '^\[\d+:\d+:\d+\] \[(.+)\]: <(.+)> (.+)$'
    message = log.match(message_legexp)
    return "<#{message[2]}> #{message[3]}" if message

    # それ以外はそのまま出力
    log
  end
end
