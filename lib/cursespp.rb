require "curses"

module Curses
	module Extensions
		def self.extended base 
			base.class_eval do
				def self.start &blck
					begin
						init_screen
						init_color if can_change_color?
						yield stdscr
					ensure
						close_screen
					end
				end

				def self.start_eval &blck
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

				def self.display message = nil, &blck
					stdscr.display message, &blck
				end #def self.display

				def self.cursor
					stdscr.cursor
				end # def self.cursor
			end
		end
	end # module Extensions
end # module Curses

require_relative "window.rb"

Curses.extend Curses::Extensions
Curses::Window.prepend Curses::WindowExtensions
Curses.stdscr.instance_variable_set "@cursor", Curses::Window::Cursor.new(Curses.stdscr)
#Curses.stdscr.instance_variable_set "@mode", Curses::Window::Mode.new( { nl: true, cr: :nocbreak, echo: :true } )
	

