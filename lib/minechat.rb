class MineChat
  def initialize
    @discord_bot = DiscordBot.new
    @mclog_monitor = MCLogMonitor.new
  end

  def start
    # discord botを起動する
    @discord_bot.run

    # minecraftのserverログを抽出する。
    Thread.start { @mclog_monitor.monitoring }
  end
end
