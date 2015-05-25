#encoding:utf-8

module Plugin_Toolkits
  #
  # => 
  #
  module_function
  #
  # => 
  #
  def unpack(number)
    data = []
    if number.is_a? Numeric
      data << ((number & 0xff000000) >> 24)
      data << ((number & 0x00ff0000) >> 16)
      data << ((number & 0x0000ff00) >> 8)
      data << (number & 0x000000ff)
    end
    data
  end
  #
  # => 
  #
  def pack(data)
    unpack(data.length).pack('C*') + data
  end
  #
  # => 
  #  return_data cmd, data1[, data2[, ... ]]
  #
  def return_data(*args)
    buffer = unpack(args.shift).pack('C*')
    args.each { |data| buffer += pack data }
    buffer
  end

end