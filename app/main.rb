#encoding: utf-8

require 'mini_magick'

require 'app/las_core/keywords'
require 'app/las_core/result'
require 'app/las_core/lexical_analyzer'

require 'app/las_plugin/toolkits'
require 'app/las_plugin/define'
require 'app/las_plugin/qrcode'
require 'app/las_plugin/barcode'
require 'app/las_plugin/inditex'
require 'app/las_plugin/mailto'


set :public_folder, 'static'

get '/entry' do
  data = params['data']

  LEXER.process data

  data = nil
  RESULT.each do |rt|
    rt[1].each do |r|
      data = r
    end
  end

  return '' if data.nil?
  return data[:description] if data[:main_data] == :compressed

  img = MiniMagick::Image.open 'app/empty.png'

  img.combine_options do |c|
    c.gravity 'North'
    c.pointsize '24'
    c.font "fonts/SourceHanSansCN-Light.otf"
    c.draw "fill #808080 text 0,4 \"#{data[:main_data]}\""

    c.gravity 'Northwest'
    c.pointsize '16'
    temp_data = data[:description].split "\n"
    temp_data.each_with_index do |str, idx|
      c.draw "fill #808080 text 8,#{48 + idx * 20} \"#{str}\""
    end
  end

  data_compressed = Zlib::Deflate.deflate(Plugin_Toolkits.return_data 0, img.to_blob)
  data_compressed
end


get '/barcode_num_generator' do

  barcode = params['barcode']
  num = barcode.split ""

  sum = 0
  num.reverse.each_with_index { |obj, idx| sum += obj.to_i if idx % 2 == 0 }
  sum *= 3
  num.reverse.each_with_index { |obj, idx| sum += obj.to_i if idx % 2 == 1 }

  rt = "#{10 - (sum % 10)}"
  rt = '0' if sum.zero?

  "0#{barcode}#{rt}"
end


get '/define' do
  URL = "http://fanyi.youdao.com/openapi.do?keyfrom=WoxLauncher&key=1247918016&type=data&doctype=json&version=1.1&q="
  uri = URI(URI.escape(URL + params['words']))
  begin
    data = Net::HTTP.get uri
    @result = JSON.parse data
  rescue
    return 'error'
  end
  rt = "#{@result["translation"].join("\n") if @result.include? "translation"}\n\
#{@result["basic"]["explains"].join("\n") if @result.include? "basic"}"
  rt.gsub /\n/, '</br>'
end


def calculate_formula(formula)
  formula.delete! " "
  formula.gsub!(/\//) { |match| "*1.0/" }
  formula.gsub!(/\^/) { |match| "**" }
  calculate_by_parenthesis formula
end

def calculate_by_parenthesis(formula)
  arr = formula.split ""
  return nil if arr.count("(") != arr.count(")")
  formula.sub!(/\([^()]*\)/) do |match|
    return nil if match =~ /[a-z]/
    subformula = match[1, match.length - 2]
    operator = ["+", "-", "*", "/", "**"]
    operator.each do |optr|
      subformula.split(optr).each do |ele|
        return nil if operator.include?(ele[0]) || operator.include?(ele[-1])
      end
    end
    eval subformula
  end
  if formula.include? "("
    calculate_by_parenthesis formula
  else
    eval formula
  end
end


# get '/calc' do
#   # calculate_formula(params['formula']).to_s
#   params['formula']
# end

require 'spreadsheet'

Spreadsheet.client_encoding = 'utf-8'

ZARA_EXCELS = [
  'countries-table.xls',
  'partes-de-las-prendas.xls',
  'textile-fibres.xls'
].map { |filename| Spreadsheet.open("data/zara/#{filename}") }

get '/zara' do
  separator = params['dash'] == '0' ? ' - ' : '/'
  data = []
  ZARA_EXCELS.each do |excel|
    excel.worksheets.each do |sheet|
      sheet.each do |row|
        row.each {|cell| cell.rstrip!; cell.upcase! }
        data << row[2] if row[0] == params['keyword'].upcase
      end
    end
  end
  data.uniq.join separator
end

LFT_EXCELS = [
  'countries-table.xls',
  'partes-de-las-prendas.xls',
  'textile-fibres.xls'
].map { |filename| Spreadsheet.open("data/lft/#{filename}") }

get '/lft' do
  separator = ' - '
  data = []
  LFT_EXCELS.each do |excel|
    excel.worksheets.each do |sheet|
      sheet.each do |row|
        row.each {|cell| cell.rstrip!; cell.upcase! }
        data << row[2] if row[0] == params['keyword'].upcase
      end
    end
  end
  data.uniq.join separator
end

BSK_EXCELS = [
  'countries-table.xls',
  'parts-of-garment.xls',
  'textile-fibers.xls'
].map { |filename| Spreadsheet.open("data/bsk/#{filename}") }

get '/bsk' do
  separator = params['dash'] == '0' ? ' - ' : '/'
  data = []
  BSK_EXCELS.each do |excel|
    excel.worksheets.each do |sheet|
      sheet.each do |row|
        row.each {|cell| cell.rstrip!; cell.upcase! }
        data << row[2] if row[0] == params['keyword'].upcase
      end
    end
  end
  data.uniq.join separator
end