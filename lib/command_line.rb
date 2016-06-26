# Display a command with curse. The class expects curses to be initialized properly
#

module Curses 
	module CommandLine
		class History 
			attr_accessor :max_size
			def initialize maxsize
				@max_size = maxsize
				@content = []
			end

			def record msg
				@content.push msg
				@content.pop if length > max_size
			end

			def length 
				@content.length
			end

			def [] (y)
				@content[y]
			end

			def last n = 1
				@content.last n
			end
		end

		attr_accessor :command_history, :default_message

		def self.extended base
			base.instance_exec do 
				@command_history = History.new 1000
				@default_message = nil
				scrollok true
				setscrreg(begx, maxx)
			end

		end

		def prompt message = nil
			m = message || default_message
			write m unless m.nil?
			refresh
			ret = getstr.chomp
			command_history.record ret
			ret
		end
	end
end
