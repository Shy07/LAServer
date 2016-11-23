#encoding: utf-8

require 'digest/md5'
require 'qrcoder'

module QRCode
  #
  # =>
  #
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
  def generate(string_data)
    @key = Digest::MD5.hexdigest string_data
    qr_filepath = "static/cache/qrcode/#{@key}.svg"
    unless File.exist? qr_filepath
      qrcode_data string_data
    end
    qr_filepath
  end
  #
  # =>
  #
  def qrcode_data(text)
    QRCoder::QRCode.image text, "static/cache/qrcode", :format => [:svg],\
                          :filename => @key, :size => 5
  end
end

HOME =  File.expand_path '..', __FILE__
AIPATH = open('illustrator_path', 'rb') {|io| io.read.strip }
path = QRCode.generate(ARGV[0]).gsub '/', "\\"

system "\"#{AIPATH}\" \"#{HOME.gsub '/', "\\"}\\#{path}\""
