require 'test/unit'
require 'libs/nagios/host.rb'
require 'libs/nagios/timeperiod.rb'
require 'libs/nagios/command.rb'
require 'libs/nagios/hostgroup.rb'

class TestHost < Test::Unit::TestCase
	def setup
		@h 	= Array.new
		@ht = Array.new
		@tp = Array.new
		@c	= Array.new
		@hg = Array.new
		
		@h << {"host_name"	=> "dbs01",
			"address"		=> "dbs01.local.domain",
			"alias"			=> "dbs01.local",
			"use"			=> "generic-dbserver-host"
			}
		@h << {"host_name"	=> "localhost",
			"address"		=> "127.0.0.1",
			"alias"			=> "localhost",
			"use"			=> "linux-servers"
			}
		@h << {"name"				=> "generic-dbserver-host",
			"contact_groups"		=> "testgroup",
			"check_command"			=> "check-host-alive",
			"max_check_attempts"	=> "3",
			"notification_options"	=> "d,u,r,f",
			"notification_interval"	=> "120",
			"notification_period"	=> "24x7",
			"register"				=> "0",
			"hostgroups"			=> "dbservers",
			"action_url"			=> "/nagios/pnp/index.php?host=$HOSTNAME$"
			}
		@tp << {"monday"		=> "00:00-24:00",
		    "tuesday"			=> "00:00-24:00",
		    "wednesday"			=> "00:00-24:00",
		    "thursday"			=> "00:00-24:00",
		    "friday"			=> "00:00-24:00",
		    "saturday"			=> "00:00-24:00",
		    "sunday"			=> "00:00-24:00",
			"alias"				=> "24 Hours/Day, 7 Days/Week",
            "timeperiod_name"	=> "24x7"
            }
		@c << {"command_name"	=> "check-host-alive",
			"command_line"		=> "$USER1$/check_ping -H $HOSTADDRESS$ -w 3000.0,80% -c 5000.0,100% -p 5"
			}
		@hg << {"hostgroup_name"	=> "dbservers",
			"alias"					=> "Database Servers"
			}
		
		@ho 	= Host.new
		@hto	= HostTemplate.new
		@tpo 	= Timeperiod.new
		@co		= Command.new
		@hgo	= Hostgroup.new
	end
	
	def test_hashify
		lh = @ho.hashify(@h)
		assert_instance_of Hash, lh
	end
	
	def test_name
		lh = @ho.hashify(@h)
		assert true, lh.has_key?('db01')
		assert true, lh.has_key?('localhost')
		assert true, lh.has_key?('generic-dbserver-host')
	end
	
	def test_address
		lh = @ho.hashify(@h)
		assert_equal 'dbs01.local.domain', lh['dbs01']['address']
		assert_equal '127.0.0.1', lh['localhost']['address']
	end
	
	def test_alias
		lh = @ho.hashify(@h)
		assert_equal 'dbs01.local', lh['dbs01']['host_alias']
		assert_equal 'localhost', lh['localhost']['host_alias']
	end
end

