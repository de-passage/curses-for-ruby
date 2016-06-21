require "curses"
require_relative "window"

module Curses
	def self.run &blck
		store_state blck
		begin
			init_screen
			init_color if can_change_color?
			instance_eval &blck
		ensure
			@initial_state_before_eval = nil
			close_screen
		end
	end

	# Redirect missing methods to the binding where run was called
	#
	def self.method_missing s, *a, &b
		@initial_state_before_eval.send s, *a, &b unless @initial_state_before_eval.nil?
	end

	def self.store_state blck
		@initial_state_before_eval = eval 'self', blck.binding
	end
	#############################################################

	# Options to process before writting text on the screen
	#
	class RenderOptions
		attr_reader :length, :text, :x ,:y, :window

		def initialize msg, window, x, y
			@text = msg
			@length = @text.length
			@window = window
			@x = x
			@y = y
		end

		def center
			@x = window.center.x - length
			@y = window.center.y
		end

	end # class RenderOptions #############################


	# Extend the basic window class
	#
	class Window
		# Track a position inside a window. By default set to 0, 0
		class Position
			attr_accessor :x, :y
			def initialize x, y
				@x = x
				@y = y
			end
		end # class Position

		# Tracks the position of the cursor
		class Cursor < Position
			def initialize ref
				super 0, 0
				@ref = ref
			end
			def refresh 
				@ref.setpos y, x
			end
		end # class Cursor
	
		#Create the cursor abstraction if needed and returns it 
		def cursor
			@cursor ||= Cursor.new self
		end # def cursor

		# Display text on the window at the given coordinates 
		def display text = nil, x = nil, y = nil
			options = RenderOptions.new text, self, x, y
			yield options if block_given?
			cursor.x = options.x unless options.x.nil?
			cursor.y = options.y unless options.y.nil?
			cursor.refresh
			write options.text 
		end # def display
		

		# Writes a message on the screen at the current cursor position
		def write message
			addstr message
			cursor.x += message.length
		end #def write

		def lines 
			maxy - begy
		end

		def cols
			maxx - begx
		end

		def center 
			Position.new maxx - cols / 2, maxy - lines / 2
		end # def center
	end # class Window ##################################

	def self.display message = nil, &blck
		stdscr.display message, &blck
	end
	
end # module Curses

