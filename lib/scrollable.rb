require_relative 'cursespp'

module Curses

	# This module is meant to extend an object providing a 'display' method
	module Scrollable
		attr_accessor :content
		attr_accessor :scroll_level

		def scroll line
			scroll_level += line
		end

		def write
		end

		def refresh
		end

	end #module Scrollable
end
