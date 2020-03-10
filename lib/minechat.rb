class MineChat
  TOKEN = Config::DISCORD_BOT[:token]
  CLIENT_ID = Config::DISCORD_BOT[:client_id]
  CONFIG = {
    token: TOKEN,
    client_id: CLIENT_ID,
    prefix:'/'
  }
  def initialize
    bot = Discordrb::Commands::CommandBot.new (CONFIG)
    @discord_bot = DiscordBot.new(bot)
    @mclog_monitor = MCLogMonitor.new(bot)
  end

  def start
    # minecraftのserverログを抽出する。
    Thread.start { @mclog_monitor.monitoring }

    # discord botを起動する
    @discord_bot.run
  end
end
