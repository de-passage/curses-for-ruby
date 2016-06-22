require_relative 'cursespp'

#Has to support scrolling both vertically and horizontally

module Curses

	# This module is meant to extend a Curses::Window object
	module Scrollable
		attr_accessor :allow_infinite_scrolling

		def scroll line
			new_sl = scroll_level + line
			if new_sl < 0 
				new_sl = 0
			elsif !allow_infinite_scrolling && new_sl > scroll_max
				new_sl = scroll_max
			end
			set_scroll_level new_sl
		end

		def write message
			#Add the message at the right place in the content array
			#Check the length
		end

		def scroll_max
			return nil if allow_infinite_scrolling

		end

		def scroll_level
			@scroll_level ||= 0
		end

		private 
		def set_scroll_level lvl
			@scroll_level = 0
			#Rewrite the window
		end

	end #module Scrollable
end
