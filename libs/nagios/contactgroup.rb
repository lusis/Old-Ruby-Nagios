# TODO
# validation methods
#
require 'libs/nagios/nagios'

class Contactgroup
	@@o = %w[contactgroup_name alias members]
	@@o.each {|x| send(:attr_accessor, x)}
	@members = Array.new
	@@contactgroups = Hash.new
	
	def initialize
		@@o.each {|x| self.instance_variable_set("@" + x, String.new)}
	end
	
	def import(phash)
		lh = Hash.new
		lh['members'] = Array.new
		phash['members'].split(',').each {|x| lh['members'] << x.strip} if phash.has_key?('members')
		lh['contactgroup_name'] = phash['contactgroup_name'] if phash.has_key?('contactgroup_name')
		lh['alias'] = phash['alias'] if phash.has_key?('alias')
		@@o.each {|x| self.instance_variable_set("@" + x, lh[x]) }
		self.register
	end
	
	def add(phash)
		#self.validate(contactgroup_hash)
		@@contactgroups.merge!(phash)
	end
	
	def register
		lh = Hash.new
		lhd = Hash.new
		cn = self.contactgroup_name
		@@o.each {|x| y = x.to_sym; lhd.merge!(y => self.instance_variable_get("@#{x}")) unless self.instance_variable_get("@#{x}") == nil}
		lh[cn] = lhd
		lh[cn].delete(:contactgroup_name)
		self.add(lh)
	end
	
	def denormalize
		lh = Marshal.load(Marshal.dump(self.list))
		lh.each_key do |y|
			mhash = Hash.new
			lh[y][:members].each do |x|
				mhash[x] = Hash.new
				mhash[x] = Nagios.flatten_contact(x)
			end
			lh[y][:members] = Hash.new
			lh[y][:members].merge!(mhash)
		end
		return lh
	end

	alias flatten denormalize
	
	def list
		return @@contactgroups
	end
	
	#def validate(contactgroup_hash)
	#	# Validate that the hash isn't empty
	#	raise ArgumentError.new("Empty contactgroup hash passed") if contactgroup_hash.empty?
	#	
	#	# Validate that it's a hash
	#	raise ArgumentError.new("Data passed was not a hash") if contactgroup_hash.class != Hash
	#	
	#	# Validate that all the data is there
	#	required_keys = %w[contactgroup_alias members]
	#	contactgroup_hash.each_key {|k|
	#		raise ArgumentError.new("You must define at least ONE member") if contactgroup_hash[k]['members'].length < 1
	#		required_keys.each {|x|
	#			raise ArgumentError.new("Missing alias for #{k.to_s}") if contactgroup_hash[k][x] == nil}
	#		}
	#	
	#	# Comparisons to existing data
	#	@@contactgroups.each_key {|x|
	#		contactgroup_hash.each_key {|y|
	#			raise RuntimeError.new("Duplicate record exists for #{contactgroup_hash[y]['contactgroup_name'].to_s}: #{@@contactgroups[x].to_s}") if x.inspect == y.inspect or x.to_s == y.to_s
	#			raise RuntimeError.new("Duplicate alias found for #{contactgroup_hash[y]['contactgroup_alias'].to_s}: #{@@contactgroups[x]['contactgroup_alias'].to_s}") if contactgroup_hash[y]['contactgroup_alias'].to_s == @@contactgroups[x]['contactgroup_alias'].to_s
	#			}
	#		}
	#end
	
	def finalize
	end
end
