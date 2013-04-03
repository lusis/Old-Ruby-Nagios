require 'libs/nagios/nagios'
require 'pp'
#Importer::new('/home/johnv/development/mo-nag-configs/nagios.cfg')
Importer::new('/home/johnv/nagios/nagios.cfg')
allhosts = Hash.new
allservices = Service.new.list
allhostgroups = Hostgroup.new.list

Host.new.list.each do |hostname, value|
	allhosts[hostname] = Hash.new
	allhosts[hostname].merge!(value)
	sh = Hash.new
	allservices.each do |servicename, details|
		if details.has_key?('host_name') and details['host_name'] == hostname
			print "Found match for #{hostname} - #{servicename}\n"
			desc = details['service_description']
			sh[desc] = details
		end
	end
	allhosts[hostname]['services'] = sh
end
pp allhosts