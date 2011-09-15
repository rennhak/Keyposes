#!/usr/bin/ruby
#


# This program helps us to create a proper config file for the Keypose project
class ConfigHelper # {{{

  # Constructor
  def initialize # {{{
  end # of def initialize }}}

  # This function requires user input to determine which poses correspond to which motion data frame
  # @return [Array] Array of subarrays containing all poses frames, e.g. [ [ frame, approx_begin_frame, approx_end_frame ], [..], .. ]
  def get_poses_frames # {{{
    result          = []

    total_poses     = ask_question( "How many poses do we have? [1..x]" )

    1.upto(total_poses.to_i) do |i| # {{{

      puts "\n>>>>>>>>>>>>>>>>>>> Pose #{i.to_s} <<<<<<<<<<<<<<<<<<<<<<<<<"

      frame           = ask_question( "[Frame] What is the EXACT frame for Dance Master Pose #{i.to_s} ?" )
      approx_begin    = ask_question( "[Frame] What is the EXACT frame for the BEGIN of Dance Master Pose #{i.to_s} ?" )
      approx_end      = ask_question( "[Frame] What is the EXACT frame for the END of Dance Master Pose #{i.to_s} ?" )

      result << [ frame.to_i, [ approx_begin.to_i, approx_end.to_i ] ]

      puts "\n\n\n"
    end # of 1.upto( total_poses.to_i ) # }}}

    result
  end # of def get_poses_frames }}}


  # This function will take care of the input/output handling of requiring input from the user and ask a yes/no type question.
  # @param [String] question Question to be asked.
  # @param [Array] yes_chars Array contains characters allowed as "yes" e.g. germans would use [ "j", "J" ]
  # @param [Array] no_chars Array contains characters allowed as "no"
  # @returns [Boolean] Returns a true for "yes" or a false for "no"
  def ask_polar_question question, yes_chars = %w[y Y \r], no_chars = %w[n N] # {{{
    allowed_chars = yes_chars.dup.concat( no_chars )
    print "\n#{question.to_s} [#{allowed_chars.join(", ")}]\n  > "

    # require input
    answer = nil

    while( not (( allowed_chars ).include?( answer.to_s )) ) # {{{
      answer = STDIN.gets
      answer.chomp!
      answer = "y" if( answer == "" ) # we accept enter as "yes"
      puts "You can only input for 'yes' -> [#{yes_chars.join(", ")}] or for 'no' -> [#{no_chars.join(", ")}]" unless( allowed_chars.include?( answer.to_s ) )
    end # of while }}}

    answer = ( yes_chars.include?( answer ) ) ? ( true ) : ( false )

    answer
  end # of def ask }}}


  # This function will take care of the input/output handling of requiring input from the user and ask a sentence type question.
  # @param [String] question Question to be asked.
  # @returns [String] Returns a string representing the user answer
  def ask_question question # {{{
    print "\n#{question.to_s} [Enter]\n  > "

    answer = STDIN.gets
    answer.chomp!

    answer
  end # of def ask_question }}}


  # Print poses frames takes input from get poses frames and prints in the the YAML specific config format
  # @param [Array] Array of subarrays containing all poses frames, e.g. [ [ frame, approx_begin_frame, approx_end_frame ], [..], .. ] - Input from get_poses_frames
  def print_poses_frames input
    string = input.inspect.to_s
    string.gsub!( "]],", "]],\n" )
    string.gsub!( "[[", "[\n    [" )
    string.gsub!( "]]]", "]]\n]" )
    string.gsub!( /^ \[/, "    [" )

    puts "Copy & Paste this into your YAML"
    puts "dmp: " + string
  end

end # of class ConfigHelper }}}


# Direct invocation
if __FILE__ == $0 # {{{

  config_helper = ConfigHelper.new

  poses_frames  = config_helper.get_poses_frames
  config_helper.print_poses_frames( poses_frames )

end # of if __FILE__ == $0 }}}
