#encoding:utf-8


def include_mode?(keyword)
  if keyword.downcase =~ /including (.*) microcontent/
    comp = $1.split ','
    comp.each {|c| puts c.upcase }
  end
end

include_mode? 'including cotton,viscose,modal microcontent'

__END__

require 'digest/md5'
# require 'qrcoder'

# string_data = 'https://github.com/samvincent/rqrcode-rails3'
# key = Digest::MD5.hexdigest string_data

# QRCoder::QRCode.image(string_data, "./", :format => :svg, :filename => key, :size => 5)

require 'zlib'

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

def pack(data)
  unpack(data.length).pack('C*') + data
end

def return_data(*args)
  buffer = unpack(args.shift).pack 'C*'
  args.each do |data|
    buffer += pack data
  end
  buffer
end

# str1 = 'h' * 12
# code = open('empty.png', 'rb') {|io| io.read }
# str2 = 'hello'
# data = return_data 512, str1, code, str2

# open('out00.bin', 'wb') {|io| io.write data }
# open('out01.bin', 'wb') {|io| io.write Zlib::Deflate.deflate(data) }

data = open('../data.bin', 'rb') {|io| io.read }

bytes = Zlib::Inflate.inflate(data).unpack 'C*'

cmd = bytes.shift 4
puts (cmd[0] << 24) | (cmd[1] << 16) | (cmd[2] << 8) | cmd[3]

begin
  length = bytes.shift 4
  length = (length[0] << 24) | (length[1] << 16) | (length[2] << 8) | length[3]
  puts length
  data = bytes.shift(length).pack 'C*'
  open("#{Digest::MD5.hexdigest data}.bin", 'wb') { |io| io.write data }
end until bytes.empty?

gets












# require 'mini_magick'

# img = MiniMagick::Image.open 'empty.png'

# img.combine_options do |c|
#  c.gravity 'North'
#  c.pointsize '36'
#  c.font "../fonts/SourceHanSansCN-Light.otf"
#  c.draw 'fill #808080 text 0,0 "你好"'

#  c.gravity 'Center'
#  c.pointsize '20'
#  c.draw "fill #808080 text 0,0 \"n. 表示问候， 惊奇或唤起注意时的用语\nint. 喂；哈罗\nn. (Hello)人名；(法)埃洛\""
# end

# img.write 'output.png'
# # data = img.to_blob
# # open('blob.png', 'wb') {|io| io.write data }












__END__
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'spreadsheet'

Spreadsheet.client_encoding = 'utf-8'

excels = []

[
  'countries-table.xls',
  'partes-de-las-prendas.xls',
  'textile-fibres.xls'
].each { |filename| excels << Spreadsheet.open("zara/#{filename}") }

lft = true
data = []
excels.each do |excel|
  excel.worksheets.each do |sheet|
    sheet.each do |row|
      row.each {|cell| cell.rstrip!; cell.upcase! }
      if row[0] == 'CHINA'
        if lft
          ['SPANISH', 'ENGLISH', 'PORTUGUESE'].each.with_index do |l, i|
            data[i] = row[2] if row[1] == l
          end
        else
          data << row[2]
        end
      end
    end
  end
end
puts data.uniq.join ' - '

gets