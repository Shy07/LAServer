#encoding: utf-8

module Inditex
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
  def analysis(flag, ary, type)
    case flag
    when :fast
      arg = ary.join(' ')
      key = Digest::MD5.hexdigest(arg + type.to_s)
      set_excels type
      @result = nil
      if @results_cache[key].nil?
        comp = include_mode? arg
        if comp
          data = quary_data 'including ... microcontent'
          comp.each_with_index do |c, i1|
            quary_data(c).each_with_index do |w, i2|
              data[i2].gsub! '…', '...'
              data[i2].gsub! '...', i1 < comp.size - 1 ? w + ', ...' : w
            end
          end
          @result = pack_data data, type == 1 ? '/' : ' - '
        else
          @result = pack_data quary_data(arg), type == 1 ? '/' : ' - '
        end
        @results_cache[key] = @result
      else
        @result = @results_cache[key]
      end
      RESULT << {
                  :label => :Inditex,
                  :weight => 0,
                  :iron => "",
                  :main_data => :compressed,
                  :description => compound_layout,
                  :method => nil#method(:refresh_bitmap)
                }
    when :full
    when :pre
      RESULT << {
                  :label => :Inditex,
                  :weight => 0,
                  :iron => "",
                  :main_data => 'zara1/zara2/lft',
                  :description => 'Activate Inditex plugin to query translation',
                  :method => nil
                }
    end
  end
  #
  # => 
  #
  def include_mode?(keyword)
    if keyword.downcase =~ /including (.*) microcontent/
      comp = $1.split ','
      comp
    else
      false
    end
  end
  #
  # => 
  #
  def set_excels(type)
    @excels = case type
    when 0, 1
      ZARA_EXCELS
    when 2
      LFT_EXCELS
    when 3
      BSK_EXCELS
    end
  end
  #
  # => 
  #
  def quary_data(keyword)
    data = []
    @excels.each do |excel|
      excel.worksheets.each do |sheet|
        sheet.each do |row|
          row.each {|cell| cell.rstrip!; cell.upcase! }
          data << row[2] if row[0] == keyword.upcase
        end
      end
    end
    data
  end
  #
  # => 
  #
  def pack_data(data, separator)
    data0 = data.uniq.join separator
    data1 = ""
    count = 0
    data.uniq.each_with_index do |word, index|
      data1 += separator unless index.zero?
      count += word.length + separator.length
      if count > 56
        data1 += "\n"
        count = 0
      end
      data1 += word
    end
    [data0, data1]
  end
  #
  # => 
  #
  def compound_layout
    image = MiniMagick::Image.open 'app/empty.png'

    image.combine_options do |c|
      c.gravity 'North'
      c.pointsize '24'
      c.font "fonts/SourceHanSans-Light.otf"
      c.draw "fill #808080 text 0,0 'Result:'"

      c.gravity 'Northwest'
      c.pointsize '16'
      temp_data = @result[1].split "\n"
      temp_data.each_with_index do |str, idx|
        c.draw "fill #808080 text 8,#{48 + idx * 20} \"#{str}\""
      end

      c.gravity 'South'
      c.pointsize '16'
      c.draw "fill #808080 text 0,8 'Press Enter to copy it to the clipboard.'"
    end

    Zlib::Deflate.deflate Plugin_Toolkits.return_data(0x02, image.to_blob, 
                                              Zlib::Deflate.deflate(@result[0]))
  end
  #
  # => 
  #
  analysis_zara_d = ->(flag, ary) { analysis flag, ary, 0 }
  analysis_zara_s = ->(flag, ary) { analysis flag, ary, 1 }
  analysis_lft    = ->(flag, ary) { analysis flag, ary, 2 }
  analysis_bsk    = ->(flag, ary) { analysis flag, ary, 3 }
  #
  # => 
  #
  KEYWORDS << { :zara_d => analysis_zara_d }
  KEYWORDS << { :zara_s => analysis_zara_s }
  KEYWORDS << { :zrd => analysis_zara_d }
  KEYWORDS << { :zrs => analysis_zara_s }
  KEYWORDS << { :lft => analysis_lft }
  KEYWORDS << { :bsk => analysis_bsk }
end


