#encoding: utf-8

module Define
  #
  # => 
  #
  URL = "http://fanyi.youdao.com/openapi.do?keyfrom=WoxLauncher&key=1247918016&type=data&doctype=json&version=1.1&q="
  #
  # => 
  #
  @results_cache = {}
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
        uri = URI(URI.escape(URL + arg))
        begin
          data = Net::HTTP.get uri
          @result = JSON.parse data
          if @result.include? "translation"
            @result["translation"].each do |line|
              line.insert(47, "\n") if line.length > 48
            end
          end
          if @result.include? "basic"
            @result["basic"]["explains"].each do |line|
              line.insert(47, "\n") if line.length > 48
            end
          end
          @results_cache[key] = @result
        rescue
          RESULT << {
                      :label => :define,
                      :weight => 0,
                      :iron => "",
                      :main_data => 'Error:',
                      :description => "Failed to get the translation content.\nPlease try again later.",
                      :method => nil#method(:refresh_bitmap)
                    }
          return
        end
      else
        @result = @results_cache[key]
      end
      RESULT << {
                  :label => :define,
                  :weight => 0,
                  :iron => "",
                  :main_data => (@result["translation"].join("\n") if @result.include? "translation"),
                  :description => (@result["basic"]["explains"].join("\n") if @result.include? "basic"),
                  :method => nil#method(:refresh_bitmap)
                }
    when :full
    when :pre
      RESULT << {
                  :label => :define,
                  :weight => 0,
                  :iron => "",
                  :main_data => 'def',
                  :description => 'Activate Define plugin to translate between Chinese and English',
                  :method => nil
                }
    end
  end
  #
  # => 
  #
  module_function :analysis
  KEYWORDS << { :def => method(:analysis) }
  KEYWORDS << { :define => method(:analysis) }
end


