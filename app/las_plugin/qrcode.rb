#encoding: utf-8

require 'qrcoder'

module QRCode
  #
  # => 
  #
  #
  # => 
  #
  @results_cache = {}
  ['static/cache', 'static/cache/qrcode'].each do |dir| 
    unless File.exist? dir; begin; Dir.mkdir dir; rescue; end; end 
  end
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
      string_data = ary.join ' '
      @key = Digest::MD5.hexdigest string_data
      @result = nil
      @qr_filepath = "static/cache/qrcode/#{@key}.svg"
      if @results_cache[@key].nil?
        if File.exist? @qr_filepath
          @result = open(@qr_filepath, "rb") { |io| io.read } 
        else
          @result = qrcode_data string_data
        end
        @results_cache[@key] = @result
      else
        @result = @results_cache[@key]
      end
      open(@qr_filepath, 'wb') {|io| io.write @result }
      RESULT << {
                  :label => :qrcode,
                  :weight => 0,
                  :iron => '',
                  :main_data => :compressed,
                  :description => compound_layout,
                  :method => nil
                }
    when :full
    when :pre
      RESULT << {
                  :label => :qrcode,
                  :weight => 0,
                  :iron => '',
                  :main_data => 'qr',
                  :description => 'Input text and press Enter to generate QRCode image',
                  :method => nil
                }
    end
  end
  #
  # => 
  #
  def qrcode_data(text)
    QRCoder::QRCode.image text, "static/cache/qrcode", :format => [:svg, :png],\
                          :filename => @key, :size => 5
    File.read "static/cache/qrcode/#{@key}.svg"
  end
  #
  # => 
  #
  def compound_layout
    back_image = MiniMagick::Image.open 'app/empty.png'
    fore_image = MiniMagick::Image.open "static/cache/qrcode/#{@key}.png"

    result = back_image.composite(fore_image) do |c|
      c.compose "Over"
      c.gravity 'Center'
      c.geometry "256x256+0+0"
    end

    result.combine_options do |c|
      c.gravity 'North'
      c.pointsize '32'
      c.font "fonts/SourceHanSansCN-Light.otf"
      c.draw "fill #808080 text 0,0 'Result:'"

      c.gravity 'South'
      c.pointsize '24'
      c.draw "fill #808080 text 0,8 'Press Enter to open it with Adobe Illustrator.'"
    end

    # data = result.to_blob

    Zlib::Deflate.deflate Plugin_Toolkits.return_data(0x01, result.to_blob,
                                        'open_with_ai', "#{@key}.svg", @result)
  end
  #
  # => 
  #
  KEYWORDS << { :qr => method(:analysis) }
end

