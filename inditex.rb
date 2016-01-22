#encoding: utf-8

require 'digest/md5'

require 'spreadsheet'

Spreadsheet.client_encoding = 'utf-8'

ZARA_EXCELS = [
  'countries-table.xls',
  'partes-de-las-prendas.xls',
  'textile-fibres.xls'
].map { |filename| Spreadsheet.open("data/zara/#{filename}") }

LFT_EXCELS = [
  'countries-table.xls',
  'partes-de-las-prendas.xls',
  'textile-fibres.xls'
].map { |filename| Spreadsheet.open("data/lft/#{filename}") }

BSK_EXCELS = [
  'countries-table.xls',
  'parts-of-garment.xls',
  'textile-fibers.xls'
].map { |filename| Spreadsheet.open("data/bsk/#{filename}") }


module Inditex
  #
  # =>
  #
  module_function
  #
  # =>
  #
  def generate(string_data, type, separator)
    key = Digest::MD5.hexdigest(string_data + type.to_s)
    set_excels type
    comp = include_mode? string_data
    if comp
      data = quary_data 'including ... microcontent'
      comp.each_with_index do |c, i1|
        quary_data(c).each_with_index do |w, i2|
          data[i2].gsub! '…', '...'
          data[i2].gsub! '。。。', ' ... '
          data[i2].gsub! '...', i1 < comp.size - 1 ? w + ', ...' : w
        end
      end
      @result = pack_data data, separator
    else
      @result = pack_data quary_data(string_data), separator
    end
    @result
  end
  #
  # =>
  #
  def include_mode?(keyword)
    if keyword.downcase =~ /including (.*)/
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
          row.each {|cell| cell.rstrip! }
          data << row[2] if row[0].upcase == keyword.upcase
        end
      end
    end
    data
  end
  #
  # =>
  #
  def pack_data(data, separator)
    data.uniq.join separator
  end
end

require 'win32/clipboard'
include Win32
# puts ARGV
case ARGV[0]
# when 'zara-'
#   Clipboard.set_data Inditex.generate(ARGV[1], 0, ARGV[2]), Clipboard::UNICODETEXT
when 'zara'
  Clipboard.set_data Inditex.generate(ARGV[1], 1, ARGV[2]), Clipboard::UNICODETEXT
when 'lft'
  Clipboard.set_data Inditex.generate(ARGV[1], 2, ARGV[2]), Clipboard::UNICODETEXT
when 'bsk'
  Clipboard.set_data Inditex.generate(ARGV[1], 3, ARGV[2]), Clipboard::UNICODETEXT
end
