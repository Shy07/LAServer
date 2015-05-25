#encoding:utf-8

module RESULT
  #
  # => 
  #
  @result = {}
  #
  # => 
  #
  # {
  #   :label => nil, 
  #   :weight => nil,
  #   :iron => nil, 
  #   :main_data => nil, 
  #   :description => nil, 
  #   :method => nil
  # }
  #
  module_function
  #
  # => 
  #
  def <<(hash)
    return if hash[:label].nil? || hash[:weight].nil?
    @result[hash[:label]] = [] if @result[hash[:label]].nil?
    @result[hash[:label]] << hash unless self.include? hash
  end
  #
  # => 
  #
  def empty?
    @result.empty?
  end
  #
  # => 
  #
  def clear
    @result.clear
  end
  #
  # => 
  #
  def include?(hash, remove = false)
    @result.each_key do |key|
      if key == hash[:label]
        @result[key].each_index do |i|
          if Digest::MD5.hexdigest(@result[key][i].to_s) == \
             Digest::MD5.hexdigest(hash.to_s)
            @result[key].delete_at i if remove
            return true
          end
        end
      end
    end
    return false
  end
  #
  # => 
  #
  def remove(hash)
    self.include? hash, true
  end
  #
  # => 
  #
  def each
    @result.each do |*rt|
      yield *rt
    end if block_given?
  end
  #
  # => 
  #
  def dump_data
    Marshal.dump @result
  end

end