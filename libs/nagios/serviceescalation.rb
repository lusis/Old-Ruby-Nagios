class Servicescalation
	@@o = %w[host_name hostgroup_name service_description]
	@@o += %w[contacts contact_groups]
	@@o += %w[first_notification last_notification notification_interval]
	@@o += %w[escalation_period escalation_options]
	@@o.each {|x| send(:attr_accessor, x)}
	@@serviceescalations = Hash.new
	
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
		@@serviceescalations.merge!(c_hash)
	end
	
	def _register
		lh = Hash.new
		lhd = Hash.new
		case self.host_name
		when nil
			cn = "#{self.hostgroup_name}|#{service_description}|#{self.first_notification}"
		else
			cn = "#{self.host_name}|#{service_description}|#{self.first_notification}"
		end
		@@o.each {|x| lhd.merge!(x => self.instance_variable_get("@#{x}")) unless self.instance_variable_get("@#{x}") == nil}
		lh[cn] = lhd
		self.add(lh)
	end
	
	def list
		return @@serviceescalations
	end
	
	def finalize
	end
end
