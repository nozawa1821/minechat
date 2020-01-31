class Packet
  attr_accessor :response
  attr_reader :id, :type, :data

  def initialize(data, login = false)
    @id = rand(0x100000000)
    @data = data
    @type = login ? 3 : 2
  end

  def size
    4 + 4 + @data.size + 2
  end

  def to_byte
    [size, @id, @type, @data, ''].pack('VVVa*a2')
  end
end