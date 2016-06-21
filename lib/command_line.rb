# Display a command with curse. The class expects curses to be initialized properly
#

module Curses 
	module CommandLine
		extend Scrollable
		class History < Array
			attr_accessor :max_size
			def initialize maxsize
				@max_size = maxsize
			end

			def record msg
				push msg
				pop if length > max_size
			end
		end

		attr_accessor :command_history
		attr_reader :command_history


		def initialize 
			@command_history = History.new
			@display_history = History.new
		end

		def prompt message = nil
			m = message || default_message
			write m unless m.nil?
			ret = gets.chomp
			@cmdhistory.record ret
			@displayhistory.record message + ret
		end
	end
end

#while game.running?
#	sleep 0.001
#	begin
#		print "%03d #{Interpreter.level}>" % count + " " * (Interpreter.level * 4 + 1)
#		input = gets
#		begin
#			ret = Interpreter.run input
#			if show_return_values? && Interpreter.level == 0
#				ret = 'nil' if ret.nil?
#				puts "=> " + ret.to_s 		
#			end
#		rescue ScriptError => e
#			puts  "Syntax error: " + e.message
#			puts e.backtrace
#		rescue SystemStackError => e
#			print e.message
#			loop do
#				print  "Show backtrace? (y/n): "
#				r = gets.chomp 
#				if r =~ /^y(es)?$/i
#					puts e.backtrace.to_s
#					break
#				elsif r =~ /^no?$/i
#					break
#				end
#			end
#		rescue => e
#			puts  e.message
#			puts e.backtrace
#		end
#		count += 1
#	rescue Interrupt
#		if Interpreter.reset?
#			puts "Aborted"
#			quit
#		else
#			Interpreter.reset
#			puts
#		end
#	end
#end
