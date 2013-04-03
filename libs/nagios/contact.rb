# TODO
# validation methods
#
#require 'libs/nagios/nagios'

class Contact
	@@o = %w[contact_name alias email contactgroups pager register name use]
	@@o += %w[host_notifications_enabled service_notifications_enabled]
	@@o += %w[service_notification_period host_notification_period]
	@@o += %w[service_notification_options host_notification_options]
	@@o += %w[service_notification_command host_notification_command]
	@@o += %w[can_submit_commands retain_status_information retain_non_status_information]
	@@contacts = Hash.new
	@@contacttemplates = Hash.new
	@@o.each {|x| send(:attr_accessor, x)}
	
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
		@@contacts.merge!(c_hash)
	end
	
	def _register
		lh = Hash.new
		lhd = Hash.new
		cn = self.contact_name if self.register != '0' or self.register == nil
		cn = self.name if self.register == '0'
		@@o.each {|x| y = x.to_sym; lhd.merge!(y => self.instance_variable_get("@#{x}")) unless self.instance_variable_get("@#{x}") == nil}
		lh[cn] = lhd
		self.add(lh)
		self._registertemplate(lh) if self.register == '0'
	end
	
	def _registertemplate(hash)
		hash.each do |cn,details|
			if details[:register] == '0'
				@@contacttemplates[cn] = Hash.new
				@@contacttemplates[cn] = details
				@@contacts.delete(cn)
			end
		end
	end

	def denormalize
		lh = Hash.new
		lh = Marshal.load(Marshal.dump(self.list))
		#ac = Contactgroup::new.denormalize
		lh.each_key do |c|
			# Check contactgroup membership
			#lh[c]['contactgroups'] = Array.new unless lh[c].has_key?('contactgroups') == true
			#ac.each do |cgn, cgd|
			#	lh[c]['contactgroups'] << cgn if cgd['members'].include?(c) == true
			#end
			# Check for attributes from a "use" template
			ia = Array.new
			if lh[c].has_key?(:use)
				template = lh[c][:use]
				tattrhash = Hash.new
				self.gettemplateattributes(template){|attribs| tattrhash.merge!(attribs)}
				tattrhash.each do |k,v|
					unless lh[c].has_key?(k) or k.to_s == 'register' or k.to_s == 'name' or k.to_s == 'alias' 
						ia << k unless ia.include?(k)
						lh[c][k] = v
					end
				end
			lh[c][:inherited_attributes] = ia
			end
		end
		return lh
	end
	
	alias flatten denormalize
	
	def list
		return @@contacts
	end
	
	def listtemplates
		return @@contacttemplates
	end
	
	def gettemplateattributes(templatename)
		attrhash = Hash.new
		@@contacttemplates[templatename].each do |k,v|
			if k.to_s == 'use'
				self.gettemplateattributes(v) {|y| yield y }
			else
				attrhash[k] = v
				yield attrhash
			end
		end
		attrhash.delete(:use)
	end
	
	def finalize
	end
	
end
