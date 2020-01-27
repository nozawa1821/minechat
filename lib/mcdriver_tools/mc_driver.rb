class MCDriver
  HOST = Config::MINECRAFT[:host]
  PORT = Config::MINECRAFT[:rcon_port]
  PASSWORD = Config::MINECRAFT[:rcon_password]

  def initialize
    @authorized = false
    @transfer = CommandTransfer.new(HOST, PORT)
  end

  def send(message)
    # 認証処理
    authorize

    # メッセージがコマンド形式で記述されていない場合はsayコマンドを実行する
    message = "/say #{message}"

    # minecraft serverに送信する
    response = @transfer.send(message)

    response
  end

  private

  def authorize
    # すでにログイン済みの場合はtrueを返す
    return true if authorized?

    result = @transfer.authorize(PASSWORD)

    @authorized = result
  end

  # 認証済みかどうかを確認する
  # @return [Boolean]
  def authorized?
    @authorized
  end
end
