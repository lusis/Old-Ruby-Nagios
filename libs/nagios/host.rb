# TODO
# validation methods
#
#require 'libs/nagios/nagios'

class Host
	@@o =  %w[host_name alias display_name address parents]
	@@o +=  %w[hostgroups name register use]
	@@o +=  %w[check_command initial_state max_check_attempts]
	@@o +=  %w[check_interval retry_interval active_checks_enabled]
	@@o +=  %w[passive_checks_enabled check_period obsess_over_host]
	@@o +=  %w[check_freshness event_handler event_handler_enabled]
	@@o +=  %w[low_flap_threshold high_flap_threshold]
	@@o +=  %w[flap_detection_enabled flap_detection_options]
	@@o +=  %w[process_perf_data retain_status_information]
	@@o +=  %w[retain_nonstatus_information contacts contact_groups]
	@@o +=  %w[notification_interval first_notification_delay]
	@@o +=  %w[notification_period notification_options]
	@@o +=  %w[notifications_enabled stalking_options]
	@@o +=  %w[notes notes_url action_url icon_image icon_image_alt]
	@@o +=  %w[vrml_image statusmap_image coords_2d coords_3d]
	@@o.each {|x| send(:attr_accessor, x)}
	@@hosts = Hash.new
	@@hosttemplates = Hash.new

	def initialize
		@@o.each {|x| self.instance_variable_set("@" + x, String.new)}
	end
	
	def self.new
		super
	end
	
	def import(phash)
		lh = Hash.new
		lh.merge!(phash)
		@@o.each {|x| self.instance_variable_set("@" + x, lh[x]) }
		self._register
	end
	
	def add(phash)
		#self.validate(contactgroup_hash)
		@@hosts.merge!(phash)
	end
	
	def _register
		lh = Hash.new
		lhd = Hash.new
		cn = self.host_name if self.register != '0' or self.register == nil
		cn = self.name if self.register == '0'
		@@o.each {|x| y =x.to_sym; lhd.merge!(y => self.instance_variable_get("@#{x}")) unless self.instance_variable_get("@#{x}") == nil}
		lh[cn] = lhd
		self.add(lh)
		self._registertemplate(lh) if self.register == '0'
	end

	def _registertemplate(hash)
		hash.each do |hn,details|
			if details[:register] == '0'
				@@hosttemplates[hn] = Hash.new
				@@hosttemplates[hn] = details
				@@hosts.delete(hn)
			end
		end
	end
	
	def list
		return @@hosts
	end
	
	def listtemplates
		return @@hosttemplates
	end

	def gettemplateattributes(templatename)
		attrhash = Hash.new
		@@hosttemplates[templatename].each do |k,v|
			if k.to_s == 'use'
				self.gettemplateattributes(v) {|y| yield y }
			else
				attrhash[k] = v
				yield attrhash
			end
		end
		attrhash.delete(:use)
	end
	
	def denormalize
		lh = Marshal.load(Marshal.dump(self.list))
		lh.each_key do |host|
			# Array to hold the inherited attributes
			ia = Array.new
			if lh[host].has_key?(:use)
				template = lh[host][:use]
				tattrhash = Hash.new
				self.gettemplateattributes(template){|attribs| tattrhash.merge!(attribs)}
				tattrhash.each do |k,v|
					unless lh[host].has_key?(k) or k.to_s == 'register' or k.to_s == 'name'
						ia << k unless ia.include?(k)
						lh[host][k] = v
					end
				end
			lh[host][:inherited_attributes] = ia
			end
		end
	end

	alias flatten denormalize
	
	def getbyname(str)
		return @@hosts[str]
	end
	
	def finalize
	end
end