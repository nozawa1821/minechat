class MineChat
  CONFIG = {
    token: Config::TOKEN,
    client_id: Config::CLIENT_ID,
    prefix:'/'
  }

  def initialize
    @bot = Discordrb::Commands::CommandBot.new (CONFIG)
  end

  def start
    @bot.command :hello do |event|
      event.send_message("hallo,world.#{event.user.name}")
    end

    @bot.run
  end
end
