require 'libs/nagios/nagios'
#require 'pp'
Importer::new('/home/johnv/development/mo-nag-configs/nagios.cfg')
#Importer::new('/home/johnv/nagios/nagios.cfg')
pp Hostgroup::new::denormalize

