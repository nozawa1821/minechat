class CommandTransfer

  def initialize(host, port)
    @mutex = Mutex.new
    @cond = ConditionVariable.new
    @socket = TCPSocket.open(host, port)
    @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
    @thread = Thread.new {read}

    @waiting = {}
  end

  # 送信処理
  def send(data)
    # 送信する内容をパケット化する
    packet = Packet.new(data)

    # minecraftサーバー宛に送信する
    request_packets(packet)

    # レスポンス受け取り処理のプロセスをキル
    Thread.kill(@thread)

    # サーバーレスポンスを取得する
    packet.response
  rescue => e
    raise e
  end

  # minecraft rconの認証を行う
  # @return [Boolean]
  def authorize(password)
    # 送信処理
    packet = Packet.new(password, true)
    request_packets(packet, 1)

    # レスポンスが帰ってきていればtrueを返す
    !!packet.response
  end

  private
  # minecraftサーバー宛に送信処理を行う
  def request_packets(packet, timeout = 10)
    @mutex.synchronize do
      @waiting[packet.id] = packet
      @socket.write(packet.to_byte)
      @socket.flush

      @cond.wait(@mutex, timeout)
    end
  end

  # レスポンス受け取り
  def read
    loop do
      size, id, type = @socket.read(12).unpack('VVV')
      data = @socket.read(size - 8)[0...-2]
      notify(id, data)
    end
  rescue => e
    raise e
  end

  def notify(id, data)
    @mutex.synchronize do
      @cond.signal if id == -1

      packet = @waiting[id]

      return unless packet

      packet.response = data

      @waiting.delete(id)

      @cond.signal if @waiting.empty?
    end
  end
end
