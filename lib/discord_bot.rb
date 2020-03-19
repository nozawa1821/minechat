class DiscordBot
  def initialize(bot)
    @discord_bot = bot
  end

  def run
    # 権限を取得しdiscord_botに反映させる
    DISCORD_USERS.list.each { |user| @discord_bot.set_user_permission(user[:id], user[:permission_level]) }

    # glhf :)
    @discord_bot.command(:hello_world, description: '動作確認用コマンド') { |event| event.send_message("HELLO WORLD. #{event.user.name}") }
    # ユーザーの一覧表示
    @discord_bot.command(:user_list, description: I18n.t("discord_bot.command.user_list.desc")) { |event| exec_discord_command(event, :user_list) }
    # コマンドの一覧表示
    @discord_bot.command(:command_list, description: I18n.t("discord_bot.command.command_list.desc")) { |event| exec_discord_command(event, :command_list) }
    # minecraftで実行できるコマンドを追加
    @discord_bot.command(:add_command, description: I18n.t("discord_bot.command.add_command.desc"), permission_level: 3) { |event| exec_discord_command(event, :add_command) }
    @discord_bot.command(:ac, description: I18n.t("discord_bot.command.add_command.desc"), permission_level: 3) { |event| exec_discord_command(event, :add_command) }
    # TODO: コマンドの権限レベルを変更
    # TODO: コマンドの削除
    # TODO: ユーザーの権限レベルを変更

    # 取得した内容をパースし、コマンドの実行もしくはminecraftに内容を送信する
    @discord_bot.message do |event|
      user_id = event.user.id
      user_name = event.user.name # 発言者
      message = event.message.content # 発言内容
      # event.message.timestamp # 発言時間

      # コマンドがdiscordのコマンドであれば処理をスキップ
      next if discord_command?(message)

      # ユーザー情報の取得。なければユーザーを登録
      user = DISCORD_USERS.registed?(user_id) ? DISCORD_USERS.find(discord_id: user_id) : add_user(user_id, user_name, event)

      # 発言内容をminecraft serverに送信する
      mc_driver = MCDriver.new(event)
      result = mc_driver.send(user_name, message)

      # 送信が成功しなかった場合、discordのチャットに送信失敗を出力する
      event.respond(mc_driver.error_message) unless result
    end

    @discord_bot.run
  rescue => e
    puts "discordbot側でエラーが発生しました：#{e}"
  end

  private
  # コマンドがdiscordのコマンドであれば、trueを返す
  def discord_command?(message)
    discord_command = message.match(/^\/(?<command>\w+).*$/)
    @discord_bot.commands.keys.any?(discord_command[:command].intern) if discord_command.present?
  end

  def exec_discord_command(event, discord_command)
    user_id = event.user.id # ユーザーID
    user_name = event.user.name # 発言者
    command = event.message.content # メッセージ

    # TODO: userの権限レベルを取得
    user = DISCORD_USERS.registed?(user_id) ? DISCORD_USERS.find(discord_id: user_id) : add_user(user_id, user_name, event)

    case discord_command
    when :user_list
      event.send_message('<ユーザー名> - <権限レベル>')
      DISCORD_USERS.list.each {|user_record| event.send_message("#{user_record[:name]} - #{user_record[:permission_level]}")}
    when :command_list
      event.send_message('<コマンド名> - <権限レベル>')
      COMMANDS.list.each {|command| event.send_message("#{command[:name]} - #{command[:permission_level]}")}
    when :add_command
      add_command(event, command)
    end

    return nil
  end

  # ユーザーの追加
  def add_user(user_id, user_name, event)
    # ユーザーがサーバー管理者の場合、権限レベルの最大値を付与する
    @discord_bot.set_user_permission(user_id, 4) if event.user.owner?
    # minechat内にも保存
    DISCORD_USERS.add_user(user_id, user_name, event.user.owner?)

    event.send_message("#{user_name}さん、祝初コメント！minechatにユーザー登録したよ")
  end

  # minecraftで実行できるコマンドの追加
  def add_command(event, command)
    regexp = /^\/add_command (?<command_name>.+) (?<permission_level>\d+)$/

    result = command.match(regexp)
    command_name = result[:command_name]
    permission_level = result[:permission_level]

    # コマンドの引数が正しい形式で渡されていなければ処理を終了する
    return event.send_message(I18n.t("discord_bot.command.execution_error.add_command")) if result.blank?
    # コマンドがすでにある場合は処理を終了する
    return event.send_message(I18n.t("discord_bot.command.already_registed", command_name: command_name)) if COMMANDS.command?(command_name)

    # TODO: コマンドを登録する
    COMMANDS.add(command_name, permission_level)

    msg = I18n.t("discord_bot.command.success", command_name: command_name, permission_level: permission_level)
    event.send_message(msg)
  end
end
