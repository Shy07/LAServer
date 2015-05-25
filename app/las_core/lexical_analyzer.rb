#encoding: utf-8
#
# => （伪）词法分析
#
#

class LexicalAnalyzer
  #
  # => 
  #
  def initialize
    @analysis_cache = {}
  end
  #
  # => 
  #
  def process(cmd)
    return if cmd.nil? || cmd.empty?
    @original_command = cmd#.downcase
    @cmd_md5 = Digest::MD5.hexdigest(@original_command)
    RESULT.clear
    if @analysis_cache.include? @cmd_md5
      analysises = @analysis_cache[@cmd_md5]
      analysises.each do |ana|
        analysis = KEYWORDS[ana[:key]]
        analysis.call ana[:flag], ana[:args]
      end
      return
    end
    @command_words = @original_command.split ' '
    pre_analysis
  end
  #
  # => 
  #
  private
  #
  # => 
  #
  def fast_analysis
    key = @command_words.shift.downcase.to_sym
    analysis = KEYWORDS[key]
    unless analysis.nil?
      analysis.call :fast, @command_words
      @analysis_cache[@cmd_md5] = []
      @analysis_cache[@cmd_md5] << {
                                      :key => key,
                                      :flag => :fast,
                                      :args => @command_words
                                   }
    end
  end
  #
  # => 
  #
  def full_analysis
    "full_analysis"
  end
  #
  # => 
  #
  def pre_analysis
    return fast_analysis unless @command_words.size < 2
    @cmd_words = @command_words.shift
    need_full_analysis = true
    KEYWORDS.each_key do |key|
      temp = key.to_s
      if @cmd_words.length <= temp.length
        if @cmd_words == temp[0, @cmd_words.length]
          analysis = KEYWORDS[key]
          analysis.call :pre, @command_words
          @analysis_cache[@cmd_md5] = [] if @analysis_cache[@cmd_md5].nil?
          @analysis_cache[@cmd_md5] << {
                                          :key => key,
                                          :flag => :pre,
                                          :args => @command_words
                                       }
          need_full_analysis = false
        end
      end
    end
    full_analysis if need_full_analysis
  end

end

LEXER = LexicalAnalyzer.new
