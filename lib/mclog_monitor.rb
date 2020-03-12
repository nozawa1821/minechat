class MCLogMonitor
  LOG_FILE_PATH = Config::MINECRAFT[:monitored_log]
  CHANNEL_ID = Config::DISCORD_BOT[:channel_id]

  def initialize(discord_bot)
    @logfile = File.open(LOG_FILE_PATH, 'r')
    @discord_bot = discord_bot
  end

  # ログの最終行を監視する
  def monitoring
    line = nil
    @logfile.seek(0, IO::SEEK_END)

    # ログに更新があった場合に処理が動く
    loop do
      new_line = @logfile.gets

      if (line != new_line)
        send_log(convert_message(new_line))
        line = new_line
      end

      sleep 0.5
    end
  end

  # ログを送信する処理
  def send_log(message)
    return if message == nil

    @discord_bot.send_message(CHANNEL_ID, message)
    puts "discordにログを送信しました：#{message}"
  end

  # 全ログを変換する処理
  # 送信対象ではない場合nilを返す
  def convert_message(log)
    return nil if log == nil

    # rconに関するログを排除
    rcon_msg_regexp = '\[\d+:\d+:\d+\] \[.+\]: \[Rcon\] (.+)'
    rcon_info_regexp = '^\[\d+:\d+:\d+\] \[.+\]: Rcon .+$'
    return nil if log.match(rcon_msg_regexp) || log.match(rcon_info_regexp)

    # chatメッセージの場合は整形する
    chat_regexp = '^\[\d+:\d+:\d+\] \[(.+)\]: <(.+)> (.+)$'
    message = log.match(chat_regexp)
    return convert_chat_message(message[2], message[3]) if message

    # それ以外はテンプレートに一致すれば出力する
    log_regexp = '^\[\d+:\d+:\d+\] \[.+\]: (.+)$'
    log_msg = log.match(log_regexp)
    return convert_server_log(log_msg[1]) if log_msg

    nil
  end

  private
  def convert_chat_message(user_name, message)
    # メッセージから不要な文字列、空白を削除
    message.slice!('[m')
    message.strip!

    "<#{user_name}> #{message}"
  end

  # serverログの変換
  def convert_server_log(log_message)
    mclog_converter = LogConverter.new(log_message)
    mclog_converter.start
  end
end
