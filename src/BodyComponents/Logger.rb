#!/usr/bin/ruby
#

###
#
# File: Logger.rb
#
######


###
#
# (c) 2009-2011, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       Logger.rb
# @author     Bjoern Rennhak
#
#######



class Logger # {{{

  # Constructor
  def initialize options # {{{
    @options = options
  end # of def initialize }}}


  # The function message will take a message as argument as well as a level (e.g. "info", "ok", "error", "question", "debug", "warning") which then would print 
  #   ( "(--) msg..", "(II) msg..", "(EE) msg..", "(??) msg.. (WW) msg..")
  #
  # @param [Symbol]   level   Ruby symbol, can either be :info, :success, :error or :question, :warning
  # @param [String]   msg     String, which represents the message you want to send to stdout (info, ok, question) stderr (error)
  #
  # Helpers: colorize
  def message level, msg # {{{

    # Pre-condition check {{{
    raise ArugmentError, "The argument level should be of type symbol, but it is (#{level.class.to_s})" unless( level.is_a?(Symbol) )
    raise ArgumentError, "The argument msg should be of type string, but it is (#{msg.class.to_s})" unless( msg.is_a?(String) )
    # }}}

    symbols = {
      :info      => "(--)",
      :success   => "(II)",
      :error     => "(EE)",
      :question  => "(??)",
      :debug     => "(++)",
      :warning   => "(WW)"
    }

    raise ArugmentError, "Can't find the corresponding symbol for this message level (#{level.to_s}) - is the spelling wrong?" unless( symbols.key?( level )  )

    if( @options.colorize )
      if( level == :error )
        STDERR.puts colorize( "LightRed", "#{symbols[ level ].to_s} #{msg.to_s}" )
      else
        STDOUT.puts colorize( "LightGreen", "#{symbols[ level ].to_s} #{msg.to_s}" ) if( level == :success )
        STDOUT.puts colorize( "LightCyan", "#{symbols[ level ].to_s} #{msg.to_s}" ) if( level == :question )
        STDOUT.puts colorize( "Brown", "#{symbols[ level ].to_s} #{msg.to_s}" ) if( level == :info )
        STDOUT.puts colorize( "LightBlue", "#{symbols[ level ].to_s} #{msg.to_s}" ) if( level == :debug and @options.debug )
        STDOUT.puts colorize( "Yellow", "#{symbols[ level ].to_s} #{msg.to_s}" ) if( level == :warning )
      end
    else
      if( level == :error )
        STDERR.puts "#{symbols[ level ].to_s} #{msg.to_s}" 
      else
        STDOUT.puts "#{symbols[ level ].to_s} #{msg.to_s}" if( level == :success )
        STDOUT.puts "#{symbols[ level ].to_s} #{msg.to_s}" if( level == :question )
 	       STDOUT.puts "#{symbols[ level ].to_s} #{msg.to_s}" if( level == :info )
        STDOUT.puts "#{symbols[ level ].to_s} #{msg.to_s}" if( level == :debug and @options.debug )
        STDOUT.puts "#{symbols[ level ].to_s} #{msg.to_s}" if( level == :warning )
      end
    end # of if( @config.colorize )

  end # of def message }}}


  # The function colorize takes a message and wraps it into standard color commands such as for bash.
  #
  # @param    [String]    color     String, of the colorname in plain english. e.g. "LightGray", "Gray", "Red", "BrightRed"
  # @param    [String]    message   String, of the message which should be wrapped
  # @returns  [String]              Colorized message string
  #
  # WARNING: Might not work for your terminal
  # FIXME: Implement bold behavior
  # FIXME: This method is currently b0rked
  def colorize color, message # {{{

    # Pre-condition check {{{
    raise ArgumentError, "The color argument should be of type String, but is (#{color.class.to_s})" unless( color.is_a?(String) )
    raise ArgumentError, "The messsage argument should be of type String, but is (#{message.class.to_s})" unless( message.is_a?(String) )
    # }}}

    # Main
    #
    # Black       0;30     Dark Gray     1;30
    # Blue        0;34     Light Blue    1;34
    # Green       0;32     Light Green   1;32
    # Cyan        0;36     Light Cyan    1;36
    # Red         0;31     Light Red     1;31
    # Purple      0;35     Light Purple  1;35
    # Brown       0;33     Yellow        1;33
    # Light Gray  0;37     White         1;37

    colors  = { 
      "Gray"        => "\e[1;30m",
      "LightGray"   => "\e[0;37m",
      "Cyan"        => "\e[0;36m",
      "LightCyan"   => "\e[1;36m",
      "Blue"        => "\e[0;34m",
      "LightBlue"   => "\e[1;34m",
      "Green"       => "\e[0;32m",
      "LightGreen"  => "\e[1;32m",
      "Red"         => "\e[0;31m",
      "LightRed"    => "\e[1;31m",
      "Purple"      => "\e[0;35m",
      "LightPurple" => "\e[1;35m",
      "Brown"       => "\e[0;33m",
      "Yellow"      => "\e[1;33m",
      "White"       => "\e[1;37m"
    }
    nocolor    = "\e[0m"

    raise ArgumentError, "This color (#{color.to_s}) is unknown to the Logger::colorize function" unless( colors.keys.include?( color ) )

    result = colors[ color ] + message + nocolor

    # Post-condition check
    raise ArgumentError, "Result of this function should be of type string, but it is (#{result.class.to_s})" unless( result.is_a?( String ) )

    result
  end # of def colorize }}}


end # of class Logger }}}


# Direct Invocation
if __FILE__ == $0 # {{{

end # of if __FILE__ == $0 }}}
