# TODO
# Create method for populating attr_accessors for @@nagios_objects with data from each class

module Munge
	def to_ivar(string)
		self.send(string.to_s + "s")
	end
end

class Importer
	include Munge
	
	def initialize(cfgfile)
		@objects = Hash.new
		self.read_nagioscfg(cfgfile)
	end

	def open_objects_directory(cfg_dir)
		Find.find(cfg_dir) do |f|
			self.open_objects_file(f) if f =~ /.cfg$/
		end
	end

	def open_objects_file(cfg_file)
		@cfg = File.open(cfg_file, "r")
		self.parse_objects
	end

	def read_nagioscfg(nagioscfg)
		@nagioscfg = File.open(nagioscfg, "r")
		@nagioscfg.each do |line|
			line.strip!
			if line =~ /^cfg_dir/
				x,y = line.split('=')
				y.strip!
				self.open_objects_directory(y)
			end
			if line =~ /^cfg_file/
				x,y = line.split('=')
				y.strip!
				self.open_objects_file(y)
			end
		end
	end

	def parse_objects
		@cfg.each do |line|
			line.strip!
			if line =~ /^define/
				def_start, object_type, open_brace = line.split
				object_type.gsub!(/\{/,'') if object_type.include? "{"
				lh = {}
				@cfg.each do |line|
					line.strip!
					next if line =~ /^#.*/  		# Ignore comments
					next if line =~ /^\s*$/ 		# Ignore empty lines
					line.gsub!(/(.*)(;.*$)/, '\1')		# Clean inline comments from the line
					line.strip!				# Sanity check of whitespace
					next if line =~ /^\s*$/
					break if line =~ /\}/			# Break out if we hit the end of an object
					object_parameter, object_value = line.split(nil,2)	# param/value
					lh[object_parameter] = object_value
				end
				self.register_object_attributes(object_type,lh)
			end
		end
	end

	def register_object_attributes(obj_type,obj_attr_hash)
		cn = obj_type.capitalize.to_class.new
		lobject = Hash.new
		lobject.merge!(obj_attr_hash)
		cn.import(lobject)
	end

	def get_all_objects_of_type(obj_type)
		return obj_type.capitalize.to_class.new.list
	end
		
end
