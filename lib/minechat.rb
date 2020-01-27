class MineChat
  def initialize
    @discord_bot = DiscordBot.new
  end

  def start
    # discord botを起動する
    @discord_bot.run
  end
end
