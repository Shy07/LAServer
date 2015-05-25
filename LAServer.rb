#encoding:utf-8

$HOMEPATH = Dir.pwd
$contacts = open("data/contacts", "rb") { |io| Marshal.load io }

require 'digest/md5'
require 'enc/encdb'
require 'net/http'
require 'json'
require 'zlib'

require 'sinatra'

get '/' do
  'Hello, this is L.A.Server.'
end

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'app/main'