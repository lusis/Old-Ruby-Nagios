require 'yaml'
require 'find'
require 'libs/nagios/cfgwriter'
require 'libs/nagios/command'
require 'libs/nagios/contact'
require 'libs/nagios/contactgroup'
require 'libs/nagios/host'
require 'libs/nagios/hostgroup'
require 'libs/nagios/service'
require 'libs/nagios/servicedependency'
require 'libs/nagios/hostdependency'
require 'libs/nagios/servicegroup'
require 'libs/nagios/timeperiod'
require 'libs/nagios/hostgroupescalation'
require 'libs/nagios/importer'

class String
	def to_class
		begin
			Kernel.const_get(self)
		rescue
			raise "No such Nagios object (#{self})"
		end
	end
end

class Class
	def cattr_reader(*cvs)
		cvs.each do |cv|
			class_eval %Q[
				def self.#{cv}; @@#{cv} end
			]
		end
	end	
end

class Nagios
	class << self
		def method_missing(symbol, *arg)
			if symbol.to_s =~ /^flatten_(\w+)$/
				obj = $1
				obj.chomp!('s') if obj =~ /^.*s/
				cn = obj.capitalize.to_class.new
				case arg.size
				when 0
					return cn.flatten
				when 1
					return cn.flatten[arg.to_s]
				end
			elsif symbol.to_s =~ /^find_(\w+)$/
				obj = $1
				obj.chomp!('s') if obj =~ /^.*s/
				cn = obj.capitalize.to_class.new
				case arg.size
				when 0
					return cn.list
				when 1
					return cn.list[arg.to_s]
				end				
			else
				super
			end
		end
	end

	def detailedhosthash
		allhosts = Marshal.load(Marshal.dump(Nagios::flatten_hosts))
		allservices = Marshal.load(Marshal.dump(Nagios::flatten_services))
		allcontacts = Marshal.load(Marshal.dump(Nagios::flatten_contacts))
		allhostgroups = Marshal.load(Marshal.dump(Nagios::flatten_hostgroups))
		allcontactgroups = Marshal.load(Marshal.dump(Nagios::flatten_contactgroups))
		
		allhosts.keys.each do |hn|
			sh = Hash.new
			# Service lookups
			allservices.each do |sn, sd|
				# Check for services owned by this host alone
				if sd.has_key?(:host_name) and sd[:host_name].include?(hn) == true
					desc = sd[:service_description]
					sh[desc] = Hash.new
					sh[desc] = sd
				end
				# Check for services inherited as part of its hostgroup
				if sd.has_key?(:hostgroup_name) and sd[:hostgroup_name].empty? == false
					sd[:hostgroup_name].each do |hg|
						if allhostgroups[hg][:members].include?(hn) == true
							desc = sd[:service_description]
							sh[desc] = Hash.new
							sh[desc] = sd
							#puts "#{Time.now}\t\t--#{desc}\n"
						end
					end
				end
				# Get the contacts for the services
				chash = Hash.new
				%w[contacts contact_groups].each do |z|
					x = z.to_sym
					if sd.has_key?(x)
						sd[x].each do |y|
							chash[y] = Hash.new
							case z
							when 'contacts'
								chash[y].merge!(allcontacts[y])
							when 'contact_groups'
								chash[y].merge!(allcontactgroups[y])
							end
						end
					end
				end
				sd[:subscribers] = Hash.new
				sd[:subscribers].merge!(chash)
			end
			sdh = Marshal.load(Marshal.dump(sh))
			sdh.each do |k,v|
				v.each_key do |sk|
					sks = sk.to_s
					v.delete(sk) if sks == 'contact_groups'
					v.delete(sk) if sks == 'contacts'
				end
			end
			allhosts[hn][:services] = sdh
		end
		#return self.to_html(allhosts)
		return allhosts
	end
	
end

