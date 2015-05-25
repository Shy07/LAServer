
code_str = '05923502420389'

code_arr = code_str.split ''

require 'mini_magick'
['../static/cache', '../static/cache/barcode', '../static/temp'].each { |dir| unless File.exist? dir; begin; Dir.mkdir dir; rescue; end; end }

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
    data += START_CODE
    code.split('').each_slice(2) do |s|
      5.times do |i|
        data << (0x10 | CODE_TABLE[s[0].to_i][i])
        data << CODE_TABLE[s[1].to_i][i]
      end
    end
    data + STOP_CODE
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
      result << %{<rect width="#{w}" height="#{height}" x="#{offset}" y="0" style=\
                  "fill:#000"/>} if hi == 1
      offset += w
    end

    xml_tag  = %{<?xml version="1.0" standalone="yes"?>}
    open_tag = %{<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink=\
    "http://www.w3.org/1999/xlink" xmlns:ev="http://www.w3.org/2001/xml-events" \
    width="#{offset}" height="#{height}">}
    close_tag = "</svg>"

    [xml_tag, open_tag, result, close_tag].flatten.join("\n")
  end

end

ITF25.image '05923502420389', "../static/cache/barcode", :format => [:svg, :png], :filename => 'test'





# qrcode.modules.each_index do |c|
#   tmp = []
#   qrcode.modules.each_index do |r|
#     y = c*unit + offset
#     x = r*unit + offset

#     next unless qrcode.is_dark(c, r)
#     tmp << %{<rect width="#{unit}" height="#{unit}" x="#{x}" y="#{y}" style="fill:##{color}"/>}
#   end 
#   result << tmp.join
# end
          
# if options[:fill]
#   result.unshift %{<rect width="#{dimension}" height="#{dimension}" x="0" y="0" style="fill:##{options[:fill]}"/>}
# end
          
# svg = [xml_tag, open_tag, result, close_tag].flatten.join("\n")

# code_arr.each_with_index do |n,i|
#   if (i + 1) % 2 == 0

#   else

#   end
# end



# require "sqlite3"

# # Open a database
# db = SQLite3::Database.new "test.db"

# rt = db.execute <<-SQL
# show all tables;
# SQL

# puts rt

# Create a database
# rows = db.execute <<-SQL
#   create table numbers (
#     name varchar(30),
#     val int
#   );
# SQL

# Execute a few inserts
# {
#   "one" => 1,
#   "two" => 2,
# }.each do |pair|
#   db.execute "insert into numbers values ( ?, ? )", pair
# end

# # Execute inserts with parameter markers
# # db.execute("INSERT INTO students (name, email, grade, blog) 
# #             VALUES (?, ?, ?, ?)", [@name, @email, @grade, @blog])

# # Find a few rows
# db.execute( "select * from numbers" ) do |row|
#   p row
# end