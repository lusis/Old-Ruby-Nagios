# TODO
# validation methods
#
require 'libs/nagios/nagios'

class Servicegroup
	
	@@o = %w[servicegroup_name alias members servicegroup_members notes notes_url action_url]
	@@o.each {|x| send(:attr_accessor, x)}
	@@servicegroups = Hash.new
	
	def initialize
		@@o.each {|x| self.instance_variable_set("@" + x, String.new)}
	end
	
	def import(c_hash)
		lh = Hash.new
		lh.merge!(c_hash)
		@@o.each {|x| self.instance_variable_set("@" + x, lh[x]) }
		self.register
	end
	
	def add(c_hash)
		#self.validate(c_hash)
		@@servicegroups.merge!(c_hash)
		@@o.each {|x| self.instance_variable_set("@" + x, String.new)}
	end
	
	def register
		lh = Hash.new
		lhd = Hash.new
		cn = self.servicegroup_name
		@@o.each {|x| lhd.merge!(x => self.instance_variable_get("@#{x}")) unless self.instance_variable_get("@#{x}") == nil}
		lh[cn] = lhd
		lh[cn].delete('servicegroup_name')
		self.add(lh)
	end
	
	def list
		return @@servicegroups
	end
	
	def finalize
	end
end
