# lib/argsv/config_argsv.rb
# Written by, Sohail Qayum Malik

module Config_Argsv
  SIZE_OF_SHORT_COMMAND=1
  SHORT_COMMAND_SYMBOL='-'
  SIZE_OF_SHORT_COMMAND_SYMBOL=1

  # Indexes into an instance of Array object called "arg". This named instance is returned by methods get_arg(), get_next_argv_index(), is_short_command?(), is_long_command?() and expected by get_arg_help_text(), get_arg_command_options(), get_arg_command_options_index(), get_arg_ARGV_index()
  # Common indexes
  IS_SHORT_COMMAND=0
  HELP_TEXT_INDEX=1 
  COMMAND_OPTIONS_INDEX=2 # All the name options for the same command
  INDEX_INTO_COMMAND_OPTIONS_INDEX=3 # Index into all the name options for the same command to point towards one name used at the command line  
  INDEX_INTO_ARGV_INDEX=4 # Index into the array of user given commands at the command line

  # Specific to arg object returned by is_short_command?() and is_long_command?() 
  ARGV_COMMAND_OPTION=5 # The user provided argument at CLI
  ARGV_COMMAND_OPTION_INDEX=6 # Only specific to is_short_command?(). Index into the user provided argument at CLI
  SIZE_OF_SINGLE_ARG_INSTANCE=7 # Number of elements into an array
  
  ARGV_COMMAND_OPTION_ARGC = 7 # Index into arg instance returned by method get_next_arg(argv_detail)
end
