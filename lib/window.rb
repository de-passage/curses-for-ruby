module Curses
	module WindowExtensions

		# Options to process before writting text on the screen
		class RenderOptions
			attr_reader :window
			attr_accessor :x, :y, :text

			def initialize msg, window, x, y
				@text = msg
				@window = window
				@x = x
				@y = y
			end # def initialize

			# Returns the length of the text to be displayed
			def length 
				text.length
			end # def length
			
			# Sets the rendering coordinates to match the center of the window
			def center
				@x = window.center.x - length
				@y = window.center.y
			end #def center
		end # class RenderOptions

		# Track a position inside a window
		class Position
			attr_accessor :x, :y

			def initialize x, y
				@x = x
				@y = y
			end
		end # class Position

		# Tracks the position of the cursor
		class Cursor
			attr_reader :visibility
			def initialize ref, visibility = 1
				@ref = ref
				@visibility = visibility
			end

			def x 
				@ref.curx
			end
			def y
				@ref.cury
			end
			def x= z
				@ref.set_cursor z, y
			end
			def y= z
				@ref.set_cursor x, z
			end
			def visibility= a
				@visibility = a
			end
			def dump
				{ x: x, y: y, visibility: visibility } 
			end

		end # class Cursor

		attr_reader :cursor, :parent

		# Constructor. Parameters are inverted from the classic curses function definition (because I don't get the y, x thing for coordinates)
		def initialize width, height, x = 0, y = 0, parent = Curses.stdscr
			raise RuntimeError, "Windows with negative coordinates not allowed" unless x >= 0 and y >= 0
			super(height, width, y, x)
			@cursor = Cursor.new self
			@parent = parent
			#@mode =  parent.mode.dup
		end # def initialize

		# Display text on the window at the given coordinates 
		def display text = nil, x = nil, y = nil
			options = RenderOptions.new text, self, x, y
			yield options if block_given?
			set_cursor x || cursor.x, y || cursor.y
			write options.text 
		end # def display

		# Writes a message on the screen at the current cursor position
		def write message
			if message.is_a? Array
				message.each_with_index do |e, i|
					write e
					writeln if i != message.length - 1
				end
			else
				addstr message
			end
		end #def write

		# Write a message on the screen at the current cursor position followed by a line feed
		def writeln message = nil
			write message if message
			write "\n"
		end #def writeln


		#Return the number of lines for the current window
		def lines 
			maxy - begy
		end #def lines

		#Return the number of columns for the current window
		def cols
			maxx - begx
		end #def cols

		#Return the position of the center of the window
		def center 
			Position.new maxx - cols / 2, maxy - lines / 2
		end # def center

		#Create a sub window
		def subwin width, height, x = 0, y = 0
			#Subwindows apparently can't overflow outside of their parent windows on the left or top so here it is
			raise RuntimeError, "Windows with negative coordinates not allowed" unless x >= 0 and y >= 0
			x = x + begx
			y = y + begy
			win = super height, width, y, x
			win.parent = self
		end #def subwin


		# Sets the cursor to the coordinates and give the focus to the window
		def set_cursor x, y
			set_position x, y
		end #def set_cursor

		# Sets the cursor to the coordinates without giving the focus
		def set_position x, y
			setpos y, x
		end #def set_position
	end # module WindowExtensions
end # module Curses



# Focus related functions
#		# Changes the focus to the current window
#		@@focus = Curses.stdscr
#		def focus
#			raise "Trying to give focus to a closed window" if closed?
#			old = @@focus
#			@@focus = self
#			focused
#			old.lost_focus
#		end # def focus
#		
#		# Change the mode for the current window
#		def mode 
#			yield self if block_given?
#			@mode
#		end
#
#		# Retrun true if the window has the focus 
#		def has_focus?
#			self == @@focus
#		end
#
#		def nl= n
#			@mode.nl = n
#			nl_ n if has_focus?
#		end
#		def nl 
#			nl = true
#		end
#		def nonl
#			nl = false
#		end
#		def nl?
#			@mode.nl?
#		end
#		#Accepted values are [:cbreak, :nocbreak, :raw]
#		def cbreak= n
#			@mode.cbreak = n
#			crmode_ n if has_focus?
#		end
#		def cbreak_mode
#			@mode.cbreak_mode
#		end
#		def cbreak 
#			cbreak = :cbreak
#		end
#		def nocbreak
#			cbreak = :nocbreak
#		end
#		def raw
#			cbreak = :raw
#		end
#		def crmode 
#			cbreak
#		end
#		# True or false
#		def echo= n
#			@mode.echo = n
#			echo_ n if has_focus?
#		end
#		def echo 
#			echo = true
#		end
#		def noecho
#			echo = false
#		end
#		def echo?
#			@mode.echo?
#		end
#
#		# Forces the terminal to switch to the window mode regardless of what window has the focus
#		def set_mode
#			m = @mode
#			writeln "Called with: " + m.inspect
#			nl_ 	m.nl?
#			echo_ 	m.echo?
#			crmode_ m.cbreak_mode
#		end
#
#		# Wait for a character
#		def getch 
#			focus
#			super
#		end
#
#		def close 
#			@closed = true
#		end
#		def closed?
#			@closed
#		end
#
#		private
#		def nl_ b
#			b ? Curses.nl : Curses.nonl
#		end
#		def echo_ b
#			b ? Curses.echo : Curses.noecho
#		end
#		def crmode_ m
#			case m
#			when :cbreak
#				Curses.cbreak
#			when :nocbreak
#				Curses.nocbreak
#			when :raw
#				Curses.raw
#			else
#				raise TypeError, "Invalid cbreak option #{m.cbreak_mode}" # Should not happen but you never know
#			end
#		end
#
#		# Called when a window gets the focus. Sets the terminal mode and cursor parameters to its own defaults
#		def focused
#			set_mode
#			# Set the cursor visibility and position to match the one before the focus was lost 
#			if @cursor_info
#				set_cursor @cursor_info[:x], @cursor_info[:y]
#				cursor.visibility = @cursor_info[:visibility] || cursor.visibility
#			end
#		end #def focused
#
#		protected
#		# Called when a window loses the focus. Dumps the cursor informations for later
#		def lost_focus
#			@cursor_info = cursor.dump unless closed?
#		end #def lost_focus
#
		# Store terminal window informations
#		class Mode 
#			# Initialize the mode to accepted values
#			def initialize m = { nl: true, cbreak: :cbreak, echo: true }
#				@nl = m[:nl] 
#				@cbreak = m[:cbreak]
#				@cbreak = :cbreak unless [:cbreak, :nocbreak, :raw].include? @cbreak
#				@echo = m[:echo]
#			end
#			# True or false
#			def nl= n
#				@nl = n
#			end
#			def nl 
#				@nl = true
#			end
#			def nonl
#				@nl = false
#			end
#			def nl?
#				@nl
#			end
#			#Accepted values are [:cbreak, :nocbreak, :raw]
#			def cbreak= n
#				raise unless [:cbreak, :nocbreak, :raw].include? n
#				@cbreak = n
#			end
#			def cbreak_mode
#				@cbreak
#			end
#			def cbreak 
#				@cbreak = :cbreak
#			end
#			def nocbreak
#				@cbreak = :nocbreak
#			end
#			def raw
#				@cbreak = :raw
#			end
#			# True or false
#			def echo= n
#				@nl = n
#			end
#			def echo 
#				@echo = true
#			end
#			def noecho
#				@echo = false
#			end
#			def echo?
#				@echo
#			end
#		end # class Mode
