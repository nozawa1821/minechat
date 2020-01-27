class CommandTransfer
  attr_accessor :send_interval

  def initialize(host, port)
    @send_interval = 0.005
    @mutex = Mutex.new
    @cond = ConditionVariable.new
    @socket = TCPSocket.open(host, port)
    @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
    Thread.new{read}

    @waiting = {}
  end

  # 送信処理
  def send(data)
    # 送信する内容をパケット化する
    packet = Packet.new(data)

    # minecraftサーバー宛に送信する
    request_packets(packet)

    # サーバーレスポンスを取得する
    packet.response
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
  def request_packets(packet, timeout = nil)
    @mutex.synchronize do

      @waiting[packet.id] = packet
      @socket.write(packet.to_byte)
      @socket.flush
      sleep send_interval

      @cond.wait(@mutex, timeout)
    end
  end

  def read
    loop do
      size, id, type = @socket.read(12).unpack('VVV')
      data = @socket.read(size - 8)[0...-2]
      notify(id, data)
    end
  rescue Exception => e
    p e
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