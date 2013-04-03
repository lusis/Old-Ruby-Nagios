# TODO
# validation methods
#
#require 'libs/nagios/nagios'

class Service
	@@o =  %w[host_name hostgroup_name service_description display_name servicegroups is_volatile check_command initial_state]
	@@o += %w[max_check_attempts check_interval retry_interval active_checks_enabled passive_checks_enabled check_period]
	@@o += %w[obsess_over_service check_freshness freshness_threshold event_handler event_handler_enabled]
	@@o += %w[low_flap_threshold high_flap_threshold flap_detection_enabled flap_detection_options process_perf_data]
	@@o += %w[retain_status_information retain_nonstatus_information notification_interval first_notification_delay]
	@@o += %w[notification_period notification_options notifications_enabled contacts contact_groups stalking_options]
	@@o += %w[notes notes_url action_url icon_image icon_image_alt register name use]
	@@o.each {|x| send(:attr_accessor, x)}
	@@services = Hash.new
	@@servicetemplates = Hash.new

	def initialize
		@@o.each {|x| self.instance_variable_set("@" + x, String.new)}
		%w[host_name hostgroup_name contacts contact_groups].each {|x| self.instance_variable_set("@" + x, Array.new)}
	end
	
	def import(phash)
		lh = Hash.new
		%w[host_name hostgroup_name contacts contact_groups].each do |x|
			if phash.has_key?(x)
				lh[x] = Array.new
				phash[x].split(',').each {|y| lh[x] << y.strip}
				phash.delete(x)
			end
		end
		lh.merge!(phash)
		@@o.each {|x| self.instance_variable_set("@" + x, lh[x]) }
		self._register
	end
	
	def add(phash)
		#self.validate(contactgroup_hash)
		@@services.merge!(phash)
	end
	
	def _register
		lh = Hash.new
		lhd = Hash.new
		if self.register != '0' and self.hostgroup_name.nil? == true
			cn = "#{self.host_name.join(',')}|#{self.service_description}"
		elsif self.register == '0'
			cn = self.name
		elsif self.host_name.nil? == true and self.register != '0'
			if  self.service_description == nil and self.use != nil
				# this is a hack. I need to figure out a logical flow to get the service description
				# for objects that inherit service_description from templates
				cn = "#{self.hostgroup_name.join(',')}|#{self.use}"
			else
				cn = "#{self.hostgroup_name.join(',')}|#{self.service_description}"
			end
		end
		@@o.each {|x| y = x.to_sym; lhd.merge!(y => self.instance_variable_get("@#{x}")) unless self.instance_variable_get("@#{x}") == nil}
		lh[cn] = lhd
		self.add(lh)
		self._registertemplate(lh) if self.register == '0'
	end

	def _registertemplate(hash)
		hash.each do |sn,details|
			if details[:register] == '0'
				details.delete(:register)
				details.delete(:name)
				@@servicetemplates[sn] = Hash.new
				@@servicetemplates[sn] = details
				@@services.delete(sn)
			end
		end
	end
	
	def gettemplateattributes(templatename)
		attrhash = Hash.new
		@@servicetemplates[templatename].each do |k,v|
			if k.to_s == 'use'
				self.gettemplateattributes(v) {|y| yield y }
			else
				attrhash[k] = v
				yield attrhash
			end
		end
		attrhash.delete('use')
	end

	def denormalize
		as = self.list
		at = self.listtemplates
		lh = Marshal.load(Marshal.dump(self.list))
		lh.each_key do |service|
			ia = Array.new
			if lh[service].has_key?(:use)
				template = lh[service][:use]
				tattrhash = Hash.new
				self.gettemplateattributes(template){|attribs| tattrhash.merge!(attribs)}
				tattrhash.each do |k,v|
					unless lh[service].has_key?(k) or k.to_s == 'register' or k.to_s == 'name'
						ia << k unless ia.include?(k)
						lh[service][k] = v
					end
				end
			lh[service][:inherited_attributes] = ia
			end
		end
	end

	alias flatten denormalize
	
	def listtemplates
		return @@servicetemplates
	end
	
	def list
		return @@services
	end
	
	def finalize
	end
end
