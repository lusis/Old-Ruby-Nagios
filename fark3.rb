#!/usr/bin/env ruby
require 'rubygems'
require 'libs/nagios/nagios'

#Importer::new('/home/johnv/nagios/nagios.cfg')
Importer::new('/home/johnv/development/mo-nag-configs/nagios.cfg')
#allhosts = Marshal.load(Marshal.dump(Nagios::new.detailedhostreport))
Nagios::new.detailedhostreport
