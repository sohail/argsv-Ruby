# Example-Application/example-application.rb
# Written by, Sohail Qayum Malik

# This application demonstrates the usage and smarts of argsv-ruby

lib = File.expand_path(File.join(File.dirname(__FILE__), '../lib'))
# execute this statement if condition is meat(if lib is part of LOAD_PATH)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# A constant
COMMANDS="?,/?,h,-h,help,--help(Shows the help screen)#v,-v,version,--version(Shows the current version number)#t,-t,test,--test(To test)"

require 'argsv/argsv'
require 'argsv/wrapper'

# Mandatetory
argv_detail = ArgsV::argsv(COMMANDS)

# $ DEUG=true ruby example-application.rb
if ENV['DEBUG'] == 'true'
    puts "Direct access without any abstraction, while debugging argsv-ruby"
else
    wrapped_args = ArgsV::Wrapper.new(argv_detail)

    # $ ruby example-application.rb foo bar baz
    common_args = wrapped_args.get_common_args()
    i = 0
    while i < common_args.size
        puts common_args[i]
	i = i + 1
    end

    if ( (arg = wrapped_args.get_arg("?")) )
        puts "Help found, and number of instances of help are = " + String(arg.size)
	i = 0
	while i < arg.size
	    if wrapped_args.arg_is_short(arg[i])
	        puts "It is short command"  
	    end
           
	    if wrapped_args.arg_is_long(arg[i])
	        puts "It is long command"
	    end

	    puts ARGV[wrapped_args.get_argv_index(arg[i])]

	    j = 0;
	    while j < wrapped_args.get_argc(arg[i])
                puts ARGV[wrapped_args.get_argv_index(arg[i]) + j + 1]
	        j = j + 1
	    end

	    puts wrapped_args.get_help_text(arg[i])
           
	    i = i + 1
	end
    else
        puts "Help not found"
    end	
end    
    

