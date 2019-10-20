# lib/argsv/argsv.rb
# Written by, Sohail Qayum Malik

require 'argsv/config_argsv'

module ArgsV

  module RegEx
    COMMAND_DELIMITER=/#/
    COMMENT=/\(.+\)/
    TOKEN_DELIMITER=/,/
    SHORT_COMMAND=/-..+/
  end

  NoCLIError = Class.new(StandardError)

  # Helper functions(Just a way to keep their linkage local)
  class << self
    private

      def get_arg_help_txt(arg)
        if arg.size and arg.kind_of?(Array)
          arg[Config_Argsv::HELP_TEXT_INDEX]
	else
	  nil
	end  
      end
      def get_arg_command_options(arg)
        if arg.size and arg.kind_of?(Array)
          arg[Config_Argsv::COMMAND_OPTIONS_INDEX]
	else
	  nil
	end  
      end
      def get_arg_command_options_index(arg)
        if arg.size and arg.kind_of?(Array)
          arg[Config_Argsv::INDEX_INTO_COMMAND_OPTIONS_INDEX]
	else
	  nil
	end  
      end
      def get_arg_ARGV_index(arg)
        if arg.kind_of?(Array)
          arg[Config_Argsv::INDEX_INTO_ARGV_INDEX]
	else
	  nil
	end  
      end

      def is_it_short_command?(arg)
        arg[Config_Argsv::IS_SHORT_COMMAND] 
      end

      # A long command is [--]token where a token can be any single or multicharacter entity. It matches any user provided token(txt) against all the valid long command tokens. It returns an instance of Array by the name of arg. Please read documents/arg.txt for the detailed layout 
      def is_long_command?(txt, args)
        arg = Array.new
        matched = false
	if args.kind_of?(Array)
	  i = 0
	  while i < args.size && ! matched
	    while i + 1 < args.size && args[i + 1].kind_of?(Array) && ! matched
	      j = 0
	      while j < args[i + 1].size && ! matched
	        if args[i + 1][j] == txt
		  matched = true
		  arg[Config_Argsv::IS_SHORT_COMMAND] = false
		  arg[Config_Argsv::HELP_TEXT_INDEX] = args[i]
		  arg[Config_Argsv::COMMAND_OPTIONS_INDEX] = args[i + 1]
		  arg[Config_Argsv::INDEX_INTO_COMMAND_OPTIONS_INDEX] = j
		  arg[Config_Argsv::INDEX_INTO_ARGV_INDEX] = 0
		  arg[Config_Argsv::ARGV_COMMAND_OPTION] = txt
		  arg[Config_Argsv::ARGV_COMMAND_OPTION_INDEX] = 0
		end
	        j = j + 1
	      end
	      i = i + 1
	    end
	    i = i + 1
	  end
	end
	if matched
	  return arg
	else
	  nil
	end  
      end

      # A short command is -abc(any small or capital letter number in two or more preceeded by single hyphen forms a short command).
      # The definition of legal short command is...
      # - It observes the rule of RegEx::SHORT_COMMAND regular expression
      # - Each individual letter is part of a command name(-a | a)
      # Please read documents/arg.txt for the detailed layout
      def is_short_command?(txt, args)
        matched = false
	arg = Array.new
        # Early exit
        if txt.scan(RegEx::SHORT_COMMAND)[0] != txt || ! args.kind_of?(Array)
	  return nil
	end
	i = Config_Argsv::SIZE_OF_SHORT_COMMAND_SYMBOL
        l = 0	
	begin
	  matched = false
	  j = 0
	  while j < args.size
	    while j + 1 < args.size && args[j + 1].kind_of?(Array)
	      k = 0
	      while k < args[j + 1].size
	        # i, displacement into txt
		# j, displacement into args
		# k, displacement into args[j + 1]
		if args[j + 1][k].size == Config_Argsv::SIZE_OF_SHORT_COMMAND && args[j + 1][k] == txt[i]
		  matched = true
		  arg[Config_Argsv::IS_SHORT_COMMAND + l] = true
		  arg[Config_Argsv::HELP_TEXT_INDEX + l] = args[j]
		  arg[Config_Argsv::COMMAND_OPTIONS_INDEX + l] = args[j + 1]
		  arg[Config_Argsv::INDEX_INTO_COMMAND_OPTIONS_INDEX + l] = k
		  arg[Config_Argsv::INDEX_INTO_ARGV_INDEX + l] = 0
		  arg[Config_Argsv::ARGV_COMMAND_OPTION + l] = txt
		  arg[Config_Argsv::ARGV_COMMAND_OPTION_INDEX + l] = i # Originates at Config_Argsv::SIZE_OF_SHORT_COMMAND_SYMBOL  
		  l = arg.size
		elsif args[j + 1][k].size == (Config_Argsv::SIZE_OF_SHORT_COMMAND + Config_Argsv::SIZE_OF_SHORT_COMMAND_SYMBOL) && args[j + 1][k][0] == Config_Argsv::SHORT_COMMAND_SYMBOL && args[j + 1][k][Config_Argsv::SIZE_OF_SHORT_COMMAND_SYMBOL] != Config_Argsv::SHORT_COMMAND_SYMBOL && args[j + 1][k][Config_Argsv::SIZE_OF_SHORT_COMMAND_SYMBOL] == txt[i]
		  matched = true
		  arg[Config_Argsv::IS_SHORT_COMMAND + l] = true
		  arg[Config_Argsv::HELP_TEXT_INDEX + l] = args[j]
		  arg[Config_Argsv::COMMAND_OPTIONS_INDEX + l] = args[j + 1]
		  arg[Config_Argsv::INDEX_INTO_COMMAND_OPTIONS_INDEX + l] = k
		  arg[Config_Argsv::INDEX_INTO_ARGV_INDEX + l] = 0
		  arg[Config_Argsv::ARGV_COMMAND_OPTION + l] = txt
		  arg[Config_Argsv::ARGV_COMMAND_OPTION_INDEX + l] = i # Originates at Config_Argsv::SIZE_OF_SHORT_COMMAND_SYMBOL
		  l = arg.size
	        end
	        k = k + 1
	      end
	      j = j + 1
	    end
	      j = j + 1
	  end
	  i = i + Config_Argsv::SIZE_OF_SHORT_COMMAND
	end while ( i < txt.size && matched )
	if matched
	  return arg
	else
	  return nil
	end  
      end

      def get_next_argv_index(args, arguments_index=0, arguments=ARGV)
        i = arguments_index
	if arguments.kind_of?(Array) && args.kind_of?(Array)
	  while i < arguments.size
	    if ( (arg_array = is_short_command?(arguments[i], args)) != nil )
	      j = Config_Argsv::INDEX_INTO_ARGV_INDEX
	      while j < arg_array.size
	        arg_array[j] = i
	        j = j + Config_Argsv::SIZE_OF_SINGLE_ARG_INSTANCE
	      end
	      return arg_array
	    elsif ( (arg = is_long_command?(arguments[i], args)) != nil )
	      arg[Config_Argsv::INDEX_INTO_ARGV_INDEX] = i
	      return arg
	    end
	    i = i + 1
	  end
	end
	nil
      end
  end
  # Helper functions end here

  def self.argsv(txt, arguments=ARGV)

    if arguments.kind_of?(Array) and arguments.size > 0

      args = self.args(txt)
      arg = get_next_argv_index(args)

      argv_detail = Array.new # Instances of all arg

      # TODO, Get common arguments here
      # How to do that...
      # use get_arg_ARGV_index(arg) to get the index of the first command at CLI. This index is the number of common arguments. The first common argument is at ARGV[0] and the last common argument is at ARGV[get_arg_ARGV_index(arg) - 1]
      # And... this dumb note was necessary because I, due to lack of time still unable to consiatantly develop it
      argv_detail[0] = get_arg_ARGV_index(arg)

      i = 1
   
      while arg

        argv_detail[i] = arg

        if ENV['DEBUG'] == 'true'
	  if arg[Config_Argsv::IS_SHORT_COMMAND]
	    j = Config_Argsv::HELP_TEXT_INDEX
	    while j < arg.size
	      #puts arg[j] + " Index into ARGV = " + String(arg[j - Config_Argsv::HELP_TEXT_INDEX + Config_Argsv::INDEX_INTO_ARGV_INDEX]) + " User provided command string = " + String(arg[j - Config_Argsv::HELP_TEXT_INDEX + Config_Argsv::ARGV_COMMAND_OPTION]) + " Index into the user provided command string = " + String(arg[j - Config_Argsv::HELP_TEXT_INDEX + Config_Argsv::ARGV_COMMAND_OPTION_INDEX]) + " Command to which previous index belongs to " + String(arg[j - Config_Argsv::HELP_TEXT_INDEX + Config_Argsv::ARGV_COMMAND_OPTION]) +"(Is short command)" 
	      j = j + Config_Argsv::SIZE_OF_SINGLE_ARG_INSTANCE
	    end
	  else
	    #puts get_arg_help_txt(arg) + " Index into ARGV = " + String(arg[Config_Argsv::INDEX_INTO_ARGV_INDEX])
	  end
	end  
        arg = get_next_argv_index(args, get_arg_ARGV_index(arg) + 1, arguments)
	i = i + 1
      end

      # User has not given any valid command line arguments, we need the number of common arguments
      if argv_detail.size == 1
        argv_detail[0] = arguments.size
      else
        argv_detail[argv_detail.size] = 0 # index into arg of short command
	argv_detail[argv_detail.size] = 1 # index into argv_detail
      end

      if argv_detail[0] == nil
        argv_detail[0] = 0
      end
      argv_detail
    end
  end

  def self.args(txt)
    i = 0; j = 0
    args = Array.new

    commands = get_commands(txt)

    while i < commands.size
      args[j] = get_comment(commands[i])
      j = j + 1
      args[j] = get_command(commands[i])
      j = j + 1
      i = i + 1
    end
    args
  end

  def self.get_commands(txt)
    txt.split(RegEx::COMMAND_DELIMITER)
  end

  def self.get_command(txt)
    txt = (txt.split(get_comment(txt)))[0]
    txt.split(RegEx::TOKEN_DELIMITER)
  end

  def self.get_comment(txt)
    (txt.scan(RegEx::COMMENT))[0]
  end

  def self.get_number_of_common_args(argv_detail)
    common_argc = 0
    if argv_detail.kind_of?(Array) && argv_detail.size > 0
      common_argc = argv_detail[0]
    end
    common_argc
  end

  def self.get_next_arg(argv_detail, arguments=ARGV)
    if argv_detail.kind_of?(Array) && argv_detail.size > 3
      argv_detail_index = argv_detail[argv_detail.size - 1]
      #puts argv_detail_index
      argv_detail_is_short_index = argv_detail[argv_detail.size - 2]
      #puts "--> " + String(argv_detail_is_short_index)
      argv_detail_is_short_index_specific = 0
      if argv_detail_index < (argv_detail.size - 2)
        arg = argv_detail[argv_detail_index]
	#argv_detail[argv_detail.size - 1] = argv_detail_index + 1
        if is_it_short_command?(arg)
	  if argv_detail_is_short_index*Config_Argsv::SIZE_OF_SINGLE_ARG_INSTANCE < arg.size
	    argv_detail_is_short_index_specific = argv_detail_is_short_index*Config_Argsv::SIZE_OF_SINGLE_ARG_INSTANCE
	    argv_detail[argv_detail.size - 2] = argv_detail_is_short_index + 1
	  else
	    argv_detail[argv_detail.size - 2] = 0
	    argv_detail[argv_detail.size - 1] = argv_detail_index + 1
	    return get_next_arg(argv_detail) # Recursion
	  end
	else
	  argv_detail[argv_detail.size - 1] = argv_detail_index + 1
	end  
        arg_local_instance = Array.new
	arg_local_instance[Config_Argsv::IS_SHORT_COMMAND] = arg[argv_detail_is_short_index_specific + Config_Argsv::IS_SHORT_COMMAND]
	arg_local_instance[Config_Argsv::HELP_TEXT_INDEX] = arg[argv_detail_is_short_index_specific + Config_Argsv::HELP_TEXT_INDEX]
	arg_local_instance[Config_Argsv::COMMAND_OPTIONS_INDEX] = arg[argv_detail_is_short_index_specific + Config_Argsv::COMMAND_OPTIONS_INDEX]
	arg_local_instance[Config_Argsv::INDEX_INTO_COMMAND_OPTIONS_INDEX] = arg[argv_detail_is_short_index_specific + Config_Argsv::INDEX_INTO_COMMAND_OPTIONS_INDEX]
	arg_local_instance[Config_Argsv::INDEX_INTO_ARGV_INDEX] = arg[argv_detail_is_short_index_specific + Config_Argsv::INDEX_INTO_ARGV_INDEX]
	arg_local_instance[Config_Argsv::ARGV_COMMAND_OPTION] = arg[Config_Argsv::ARGV_COMMAND_OPTION]
	arg_local_instance[Config_Argsv::ARGV_COMMAND_OPTION_INDEX] = arg[argv_detail_is_short_index_specific + Config_Argsv::ARGV_COMMAND_OPTION_INDEX]

        # Only specific to arg instances returned by this method
	if (argv_detail_index + 1) < (argv_detail.size - 2)
	  arg_local_instance[Config_Argsv::ARGV_COMMAND_OPTION_ARGC] = get_arg_ARGV_index(argv_detail[argv_detail_index + 1]) - get_arg_ARGV_index(arg_local_instance) - 1 
	else
	  arg_local_instance[Config_Argsv::ARGV_COMMAND_OPTION_ARGC] = arguments.size - get_arg_ARGV_index(arg_local_instance) - 1
	end
        return arg_local_instance
      end
    end
    nil
  end

  def self.reset_argv_detail_indexes(argv_detail)
    if argv_detail.kind_of?(Array) && argv_detail.size > 3 
      argv_detail[argv_detail.size - 2] = 0
      argv_detail[argv_detail.size - 1] = 1
    end
  end

end
