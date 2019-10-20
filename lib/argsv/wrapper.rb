# lib/argsv/wrapper.rb
# Written by, Sohail Qayum Malik

# Reference, lib/tentd/query.rb

require 'argsv/config_argsv'

module ArgsV

  class Wrapper
   
    attr_accessor :argv_detail

    def initialize(value)
      @argv_detail = value
      ArgsV.reset_argv_detail_indexes(@argv_detail)
    end

    def get_arg(txt)
      i = 0; j = 0
      args = Array.new
      arg = ArgsV.get_next_arg(argv_detail)
      while arg
        while (opt=arg[Config_Argsv::COMMAND_OPTIONS_INDEX][i])
	  if txt == opt
	    args[j] = arg
	    j = j + 1
	  end
	  i = i + 1
        end
        i = 0
	arg = ArgsV.get_next_arg(argv_detail)
      end

      ArgsV.reset_argv_detail_indexes(@argv_detail)

      if j > 0
        return args
      end
      nil
    end

    def get_common_args(arguments = ARGV)
      common_args = Array.new
      i = 0
      while i < ArgsV::get_number_of_common_args(argv_detail)
        common_args[i] = arguments[i]
        i = i + 1
      end
      common_args
    end

    def arg_is_short(arg)
      arg[Config_Argsv::IS_SHORT_COMMAND] 
    end

    def arg_is_long(arg)
      !arg_is_short(arg)
    end

    def get_argv_index(arg)
      arg[Config_Argsv::INDEX_INTO_ARGV_INDEX] 
    end

    def get_index_of_command_in_command_options(arg)
      arg[Config_Argsv::INDEX_INTO_COMMAND_OPTIONS_INDEX]
    end

    def get_help_text(arg)
      arg[Config_Argsv::HELP_TEXT_INDEX]
    end

    def get_argc(arg)
      arg[Config_Argsv::ARGV_COMMAND_OPTION_ARGC]
    end

  end
end
