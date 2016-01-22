#encoding: utf-8

set :public_folder, 'static'

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

require 'inditex.rb'

get '/zara' do
  type = params['dash'] == '0' ? 0 : 1
  Inditex.generate params['keyword'], type
end

get '/lft' do
  Inditex.generate params['keyword'], 2
end

get '/bsk' do
  Inditex.generate params['keyword'], 3
end
