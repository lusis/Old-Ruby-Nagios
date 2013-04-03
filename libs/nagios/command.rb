# TODO
# validation methods
#
require 'libs/nagios/nagios'

class Command
	@@o = %w[command_name command_line]
	@@o.each {|x| send(:attr_accessor, x)}
	@@commands = Hash.new

	def initialize
		@@o.each {|x| self.instance_variable_set("@" + x, String.new)}
	end
	
	def import(phash)
		lh = Hash.new
		lh.merge!(phash)
		@@o.each {|x| self.instance_variable_set("@" + x, lh[x]) }
		self.register
	end
	
	def add(phash)
		#self.validate(contactgroup_hash)
		@@commands.merge!(phash)
	end
	
	def register
		lh = Hash.new
		lhd = Hash.new
		cn = self.command_name
		cl = self.command_line
		lh[cn] = cl
		self.add(lh)
	end

	def list
		return @@commands
	end
	
	def finalize
	end
end