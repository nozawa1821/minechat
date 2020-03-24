class DiscordBot
  def initialize(bot)
    @discord_bot = bot
  end

  def run
    # 権限を取得しdiscord_botに反映させる
    DISCORD_USERS.list.each { |user| @discord_bot.set_user_permission(user[:id], user[:permission_level]) }

    load_command

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
  # 作成したdiscord用実行コマンドの読み込み
  def load_command
    # glhf :)
    @discord_bot.command(:hello_world, description: '動作確認用コマンド') { |event| event.send_message("HELLO WORLD. #{event.user.name}") }
    # ユーザーの一覧表示
    @discord_bot.command(:user_list, description: I18n.t("discord_bot.command.user_list.desc")) { |event| exec_discord_command(event, :user_list) }
    # コマンドの一覧表示
    @discord_bot.command(:command_list, description: I18n.t("discord_bot.command.command_list.desc")) { |event| exec_discord_command(event, :command_list) }
    # minecraftで実行できるコマンドを追加
    @discord_bot.command([:command_add, :c_add], description: I18n.t("discord_bot.command.command_add.desc"), permission_level: 3) do |event|
      exec_discord_command(event, :command_add)
    end
    # コマンドの権限レベルを変更
    @discord_bot.command([:command_chmod, :c_chmod], description: I18n.t("discord_bot.command.command_chmod.desc"), permission_level: 3) do |event|
      exec_discord_command(event, :command_chmod)
    end
    # TODO: コマンドの削除
    # ユーザーの権限レベルを変更
    @discord_bot.command(:user_chmod, description: I18n.t("discord_bot.command.user_chmod.desc"), permission_level: 3) do |event|
      exec_discord_command(event, :user_chmod)
    end
  end

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
    when :command_add
      command_add(event, command)
    when :command_chmod
      command_chmod(command, event)
    when :user_chmod
      user_chmod(command, event)
    end

    nil
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
  def command_add(event, command)
    regexp = /^\/\w+ (?<command_name>.+) (?<permission_level>\d+)$/

    result = command.match(regexp)

    # コマンドの引数が正しい形式で渡されていなければ処理を終了する
    return event.send_message(I18n.t("discord_bot.command.command_add.execution_error")) if result.blank?

    command_name = result[:command_name]
    permission_level = result[:permission_level]

    # コマンドがすでにある場合は処理を終了する
    return event.send_message(I18n.t("discord_bot.command.command_add.already_registed", command_name: command_name)) if COMMANDS.command?(command_name)

    # TODO: コマンドを登録する
    COMMANDS.add(command_name, permission_level)

    msg = I18n.t("discord_bot.command.command_add.success", command_name: command_name, permission_level: permission_level)
    event.send_message(msg)
  end

  # コマンドの実行権限をを変更する
  def command_chmod(command, event)
    regexp = /^\/\w+ (?<command_name>.+) (?<permission_level>\d+)$/
    result = command.match(regexp)

    # コマンドの引数が正しい形式で渡されていなければ処理を終了する
    return event.send_message(I18n.t("discord_bot.command.command_chmod.execution_error")) if result.blank?

    command_name = result[:command_name]
    permission_level = result[:permission_level]

    command = COMMANDS.chmod(command_name, permission_level)
    if command.present?
      event.send_message(I18n.t("discord_bot.command.command_chmod.success", command_name: command.command_name, permission_level: command.permission_level))
    else
      event.send_message(I18n.t("discord_bot.command.command_chmod.error"))
    end
  end

  # ユーザーの権限をを変更する
  def user_chmod(command, event)
    regexp = /^\/\w+ (?<user_id>.+) (?<permission_level>\d+)$/
    result = command.match(regexp)

    # コマンドの引数が正しい形式で渡されていなければ処理を終了する
    return event.send_message(I18n.t("discord_bot.command.user_chmod.execution_error")) if result.blank?

    user_id = result[:user_id]
    permission_level = result[:permission_level]

    user = DISCORD_USERS.chmod(user_id, permission_level)
    if user.present?
      @discord_bot.set_user_permission(user_id, permission_level)
      event.send_message(I18n.t("discord_bot.command.user_chmod.success", user_name: user.user_name, permission_level: user.permission_level))
    else
      event.send_message(I18n.t("discord_bot.command.user_chmod.error"))
    end
  end
end
