#encoding: utf-8

module Mailto
  #
  # => 
  #
  @results_cache = {}
  #
  # => 
  #
  module_function
  #
  # => 
  #
  def analysis(flag, ary)
    case flag
    when :fast
      arg = ary.join(' ')
      key = Digest::MD5.hexdigest(arg)
      @result = nil
      if @results_cache[key].nil?
        @result = quary_data arg
        @results_cache[key] = @result
      else
        @result = @results_cache[key]
      end
      RESULT << {
                  :label => :Mailto,
                  :weight => 0,
                  :iron => "",
                  :main_data => :compressed,
                  :description => compressed_data,
                  :method => nil#method(:refresh_bitmap)
                }
    when :full
    when :pre
      RESULT << {
                  :label => :Mailto,
                  :weight => 0,
                  :iron => "",
                  :main_data => 'mailto',
                  :description => 'Activate Mailto plugin to open e-mail window.',
                  :method => nil
                }
    end
  end
  #
  # => 
  #
  def quary_data(name)
    fullname = name.split(' ').join('').downcase
    $contacts.each do |c|
      if fullname == "#{c[:first_name_en]}#{c[:last_name_en]}".downcase ||
         fullname == "#{c[:last_name_en]}#{c[:first_name_en]}".downcase ||
         fullname == c[:first_name_en].downcase
         return c[:email]
      end
    end
    'nil'
  end
  #
  # => 
  #
  def compressed_data
    Zlib::Deflate.deflate Plugin_Toolkits.return_data(0x03, "mailto:#{@result}")
  end
  #
  # => 
  #
  KEYWORDS << { :mailto => method(:analysis) }
  KEYWORDS << { :ml2 => method(:analysis) }
end


