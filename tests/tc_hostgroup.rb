require 'test/unit'
require 'libs/nagios/hostgroup.rb'

class TestHostgroup < Test::Unit::TestCase
	def setup
		@hg = Array.new
		@hg << {"hostgroup_name"	=> "dbservers",
			"alias"					=> "Database Servers",
			"members"				=> "dbs01, dbs02, dbs03"
			}
		@hg << {"hostgroup_name"	=> "appservers",
			"alias"					=> "Application Servers"
			}
		@hgo = Hostgroup.new
	end
end

