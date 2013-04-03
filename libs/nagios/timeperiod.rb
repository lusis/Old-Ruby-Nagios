require 'libs/nagios/nagios'

# TODO
# redo validate method

class Timeperiod
	@@o = %w[timeperiod_name alias ranges]
	@@o.each {|x| send(:attr_accessor, x)}
	@@timeperiods = Hash.new
	
	def initialize
		@timeperiod_name = String.new
		@alias = String.new
		@ranges = Hash.new
	end

	def import(timeperiod_hash)
		lh = Hash.new
		r = Hash.new
		lh.merge!(timeperiod_hash)
		Date::DAYNAMES.each do |day|
			day = day.downcase
			self.ranges.merge!({day => lh[day]})
			lh.delete(day)
		end
		@@o.each do |x|
			break if x == 'ranges'
			self.instance_variable_set("@" + x, lh[x])
		end
		self.register
	end

	def add(timeperiod_hash)
		#self.validate(timeperiod_hash)
		@@timeperiods.merge!(timeperiod_hash)
	end
	
	def register
		lh = Hash.new
		lhd = Hash.new
		cn = self.timeperiod_name
		@@o.each {|x| y = x.to_sym; lhd.merge!(y => self.instance_variable_get("@#{x}")) unless self.instance_variable_get("@#{x}") == nil}
		lh[cn] = lhd
		self.add(lh)
	end
	
	def list
		return @@timeperiods
	end
	
	#def validate(timeperiod_hash)
	#	# Validate the hash isn't empty
	#	raise ArgumentError.new("Empty timeperiod hash passed") if timeperiod_hash.empty?
	#	
	#	# Comparisons to existing data
	#	@@timeperiods.each_key {|x|
	#		timeperiod_hash.each_key {|y|
	#			raise RuntimeError.new("Duplicate record exists for #{timeperiod_hash[y]['timeperiod_name'].to_s}: #{@@timeperiods[x].to_s}") if x.inspect == y.inspect or x.to_s == y.to_s
	#			raise RuntimeError.new("Duplicate alias found for #{timeperiod_hash[y]['timeperiod_alias'].to_s}: #{@@timeperiods[x]['timeperiod_alias'].to_s}") if timeperiod_hash[y]['timeperiod_alias'].to_s == @@timeperiods[x]['timeperiod_alias'].to_s
	#			}
	#		}
	#	
	#	# Validate that all the data is there
	#	required_keys = %w[timeperiod_alias ranges]
	#	timeperiod_hash.each_key {|k|
	#		raise ArgumentError.new("You must define at least ONE day range") if timeperiod_hash[k]['ranges'].length < 1
	#		required_keys.each {|x|
	#			raise ArgumentError.new("Missing alias for #{k.to_s}") if timeperiod_hash[k][x] == nil}
	#		}
	#end
	
end