# TODO
# validation methods
#
require 'libs/nagios/nagios'

class Hostgroup
	
	@@o = %w[hostgroup_name alias members hostgroup_members notes notes_url action_url]
	@@o.each {|x| send(:attr_accessor, x)}
	@@hostgroups = Hash.new
	
	def initialize
		@@o.each {|x| self.instance_variable_set("@" + x, String.new)}
		@members = Array.new
		@hostgroup_members = Array.new
	end
	
	def import(c_hash)
		lh = Hash.new
		lh['members'] = Array.new
		lh['hostgroup_members'] = Array.new
		c_hash['members'].split(',').each {|x| lh['members'] << x.strip} if c_hash.has_key?('members')
		c_hash['hostgroup_members'].split(',').each {|x| lh['hostgroup_members'] << x.strip} if c_hash.has_key?('hostgroup_members')
		c_hash.delete('members')
		c_hash.delete('hostgroup_members')
		lh.merge!(c_hash)
		@@o.each {|x| self.instance_variable_set("@" + x, lh[x]) }
		self._register
	end
	
	def add(c_hash)
		#self.validate(c_hash)
		@@hostgroups.merge!(c_hash)
		@@o.each {|x| self.instance_variable_set("@" + x, String.new)}
	end
	
	def _register
		lh = Hash.new
		lhd = Hash.new
		cn = self.hostgroup_name
		@@o.each do |x|
			y = x.to_sym
			lhd.merge!( y => self.instance_variable_get("@#{x}")) unless self.instance_variable_get("@#{x}") == nil
		end
		lh[cn] = lhd
		lh[cn].delete(:hostgroup_name)
		self.add(lh)
	end
	
	def list
		return @@hostgroups
	end
	
	def denormalize
		# Hostgroup membership can be defined in 2 places:
		# - Host.hostgroups
		# - Hostgroup.members
		ah = Host::new.list
		at = Host::new.listtemplates
		as = Service::new.list
		lh = Hash.new
		lh = Marshal.load(Marshal.dump(self.list))
		lh.each do |hg,details|
			# Parse host entries for members to add
			ah.each do |k,v|
				if v.has_key?(:hostgroups)
					v[:hostgroups].split(',').each do |x|
						lh[hg][:members] << k.strip if x == hg and v[:register] != '0'
					end
				# If he doesn't have a membership explicitly
				# Check the template he uses for group membership
				elsif v.has_key?(:use)
					at.each do |k2,v2|
							lh[hg][:members] << k.strip if v[:use] == k2 and v2[:hostgroups] == hg
					end
				end
			end
		end
		return lh
	end

	alias flatten denormalize

	def finalize
	end
end
