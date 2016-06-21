module Curses
	#module WindowExtensions
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

	#Window.prepend WindowExtensions
end
