class Hostgroupescalation
	@@o = %w[hostgroup_name]
	@@o += %w[contact_groups]
	@@o += %w[first_notification last_notification notification_interval]
	@@o.each {|x| send(:attr_accessor, x)}
	@@hostgroupescalations = Hash.new
	
	def initialize
		@@o.each {|x| self.instance_variable_set("@" + x, String.new)}
	end
	
	def import(c_hash)
		lh = Hash.new
		lh.merge!(c_hash)
		@@o.each {|x| self.instance_variable_set("@" + x, lh[x]) }
		self._register
	end
	
	def add(c_hash)
		#self.validate(c_hash)
		@@hostgroupescalations.merge!(c_hash)
	end
	
	def _register
		lh = Hash.new
		lhd = Hash.new
		cn = "#{self.hostgroup_name}|#{self.first_notification}"
		@@o.each {|x| lhd.merge!(x => self.instance_variable_get("@#{x}")) unless self.instance_variable_get("@#{x}") == nil}
		lh[cn] = lhd
		self.add(lh)
	end
	
	def list
		return @@hostgroupescalations
	end
	
	def finalize
	end
end
