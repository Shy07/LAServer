#encoding: utf-8

module KEYWORDS
  #
  # => 
  #
  @keywords = {}
  #
  # => 
  #
  module_function
  #
  # => 
  #
  def <<(hash)
    hash.each {|key, value| @keywords[key] = value }
  end
  #
  # => 
  #
  def [](key)
    @keywords[key]
  end
  #
  # => 
  #
  def include?(key)
    @keywords.include? key
  end
  #
  # => 
  #
  def each_key
    @keywords.each_key do |key|
      yield key
    end if block_given?
  end
  #
  # => 
  #
  def to_s
    @keywords.to_s
  end
end


