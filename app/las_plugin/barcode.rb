#encoding: utf-8

module Bar_Code
  #
  # => 
  #
  @results_cache = {}
  ['static/cache', 'static/cache/barcode'].each do |dir|
    unless File.exist? dir; begin; Dir.mkdir dir; rescue; end; end
  end
  #
  # => 
  #
  module ITF25
    #
    # => 
    #     0x10  black narrow
    #     0x11  black wide
    #     0x00  white narrow
    #     0x01  white wide
    #
    START_CODE = [ 0x10, 0x00, 0x10, 0x00 ]
    STOP_CODE  = [ 0x11, 0x00, 0x10 ]
    CODE_TABLE = [
      [0, 0, 1, 1, 0], # 0
      [1, 0, 0, 0, 1], # 1
      [0, 1, 0, 0, 1], # 2
      [1, 1, 0, 0, 0], # 3
      [0, 0, 1, 0, 1], # 4
      [1, 0, 1, 0, 0], # 5
      [0, 1, 1, 0, 0], # 6
      [0, 0, 0, 1, 1], # 7
      [1, 0, 0, 1, 0], # 8
      [0, 1, 0, 1, 0]  # 9
    ]
    IMAGE_FORMATS = [:jpg , :png, :gif, :tif, :bmp]
    #
    # => 
    #
    module_function
    #
    # => 
    #
    def image(code, output, format: nil, filename: nil)
      formats = []
      if format.is_a? Array
        formats = format
      else
        formats << format || :svg
      end
      filename = code if filename.nil?
      svg = self.svg(bin_data(code))

      err_f = formats - IMAGE_FORMATS - [:svg]
      raise "#{err_f.join(', ')} is not supported file formats" unless(err_f.empty?)

      begin 
        formats.each do |format|
          if IMAGE_FORMATS.include?(format)
            image = MiniMagick::Image.read(svg) { |i| i.format "svg" }
            image.format format.to_s
            image.write "#{output}/#{filename}.#{format}"
          else
            data = svg
            open("#{output}/#{filename}.#{format}", "wb") {|io| io.write data }
          end
        end
      rescue
        "File saving error"
      end

      svg
    end
    #
    # => 
    #
    def bin_data(code)
      data = []
      code.split('').each_slice(2) do |s|
        5.times do |i|
          data << (0x10 | CODE_TABLE[s[0].to_i][i])
          data << CODE_TABLE[s[1].to_i][i]
        end
      end
      START_CODE + data + STOP_CODE
    end
    #
    # => 
    #
    def svg(data)
      result = []
      offset = 0
      height = 30
      data.each do |i|
        hi, low = (i >> 4), (i & 0xf)
        w = low.zero? ? 2 : 5
        result << %{<rect width="#{w}" height="#{height}" x="#{offset}" y="0" \
style="fill:#000"/>} if hi == 1

        offset += w
      end

      xml_tag  = %{<?xml version="1.0" standalone="yes"?>}
      open_tag = %{<svg version="1.1" xmlns="http://www.w3.org/2000/svg" \
xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ev="http://www.w3.org/2001/xml\
-events" width="#{offset}" height="#{height}">}

      close_tag = "</svg>"

      [xml_tag, open_tag, result, close_tag].flatten.join("\n")
    end
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
      @bar_filepath = "static/cache/barcode/#{@key}.svg"
      if @results_cache[@key].nil?
        if File.exist? @bar_filepath
          @result = open(@bar_filepath, "rb") { |io| io.read } 
        else
          @result = barcode_data string_data
        end
        @results_cache[@key] = @result
      else
        @result = @results_cache[@key]
      end
      RESULT << {
                  :label => :barcode,
                  :weight => 0,
                  :iron => '',
                  :main_data => :compressed,
                  :description => compound_layout,
                  :method => nil
                }
    when :full
    when :pre
      RESULT << {
                  :label => :barcode,
                  :weight => 0,
                  :iron => '',
                  :main_data => 'itf',
                  :description => 'Input text and press Enter to generate barcode image',
                  :method => nil
                }
    end
  end
  #
  # => 
  #
  def barcode_data(text)
    ITF25.image text, "static/cache/barcode", format: [:svg, :png], filename: @key
  end
  #
  # => 
  #
  def compound_layout
    back_image = MiniMagick::Image.open 'app/empty.png'
    fore_image = MiniMagick::Image.open "static/cache/barcode/#{@key}.png"

    result = back_image.composite(fore_image) do |c|
      c.compose "Over"
      c.gravity 'Center'
      c.geometry "+0+0"
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
  KEYWORDS << { :itf => method(:analysis) }
end

