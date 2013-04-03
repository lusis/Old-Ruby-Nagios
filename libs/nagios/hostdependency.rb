class Hostdependency
	@@o = %w[dependent_host_name dependent_hostgroup_name]
	@@o += %w[host_name hostgroup_name register name]
	@@o += %w[inherits_parent dependency_period]
	@@o += %w[execution_failure_criteria notification_failure_criteria]
	@@o.each {|x| send(:attr_accessor, x)}
	@@hostdependencys = Hash.new
	
	def initialize
		@@o.each {|x| self.instance_variable_set("@" + x, String.new)}
	end
	
	def import(phash)
		lh = Hash.new
		lh.merge!(phash)
		@@o.each {|x| self.instance_variable_set("@" + x, lh[x]) }
		self._register
	end
	
	def add(phash)
		#self.validate(contactgroup_hash)
		@@hostdependencys.merge!(phash)
	end
	
	def _register
		lh = Hash.new
		lhd = Hash.new
		case self.register
		when "0"
			cn = self.name
		when nil
			case dependent_host_name
			when nil
				cn = self.dependent_hostgroup_name
			else
				cn = self.dependent_host_name
			end
		end
		@@o.each {|x| lhd.merge!(x => self.instance_variable_get("@#{x}")) unless self.instance_variable_get("@#{x}") == nil}
		lh[cn] = lhd
		self.add(lh)
	end

	def list
		return @@hostdependencys
	end
	
	def finalize
	end
end

