#encoding: utf-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift('../las_plugin')

require 'net/http'
require 'json'
require 'digest/md5'

require 'keywords'
require 'result'
require 'lexical_analyzer'
require 'define'

lexer = LexicalAnalyzer.new

while true
  str = gets.rstrip
  break if str.empty?
  lexer.process str
  RESULT.each {|rt| puts rt }
end

