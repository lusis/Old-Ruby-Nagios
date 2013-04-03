require 'test/unit'
require 'libs/nagios/contactgroup.rb'
require 'libs/nagios/contact.rb'

class TestContactgroup < Test::Unit::TestCase
		def setup
			@cga 	= Array.new
			@ca		= Array.new

			@cga << {"contactgroup_name"	=> "admins",
				"alias"						=> "Administrative Users",
				"members"					=> "nagiosadmin,johnv"
				}
			@cga << {"contactgroup_name"	=> "placeholder",
				"alias"						=> "Group with no members"
				}
			@ca << {"service_notification_period"=>"24x7",
				"host_notification_options"=>"d,u,r",
				"service_notification_commands"=>"notify-service-by-email",
				"host_notification_period"=>"24x7",
				"host_notification_commands"=>"notify-host-by-email",
				"service_notification_options"=>"w,u,c,r",
				"alias"=>"John E. Vincent",
				"email"=>"johnv@localhost",
				"contact_name"=>"johnv"
				}
			@ca << {"service_notification_period"=>"24x7",
				"host_notification_options"=>"d,u,r",
				"service_notification_commands"=>"notify-service-by-email",
				"host_notification_period"=>"24x7",
				"host_notification_commands"=>"notify-host-by-email",
				"service_notification_options"=>"w,u,c,r",
				"alias"=>"Nagios Administrator",
				"email"=>"nagiosadmin@localhost",
				"contact_name"=>"nagiosadmin"
				}
			
			@cgo 	= Contactgroup.new
			@co		= Contact.new
		end
		
		def test_hashify
			lh = @cgo.hashify(@cga)
			assert_instance_of Hash, lh
		end
		
		def test_contactgroup_name
			lh = @cgo.hashify(@cga)
			assert lh.has_key?('admins')
			assert lh.has_key?('placeholder')
		end
		
		def test_contactgroup_alias
			lh = @cgo.hashify(@cga)
			assert_equal 'Administrative Users', lh['admins']['contactgroup_alias']
			assert_equal 'Group with no members', lh['placeholder']['contactgroup_alias']
		end
		
		def test_contactgroup_has_members
			lh = @cgo.hashify(@cga)
			assert lh['admins'].has_key?('members')
			assert_equal 'nagiosadmin,johnv', lh['admins']['members']
		end
		
		def test_contactgroup_member_count
			lh = @cgo.hashify(@cga)
			ma = Array.new
			lh['admins']['members'].split(",").each do |member|
				member.strip!
				ma << member
			end
			assert_equal 2, ma.length
		end
		
		def test_member_validity
			lh 	= @cgo.hashify(@cga)
			lh2 = @co.hashify(@ca)
			lh['admins']['members'].split(",").each do |member|
				member.strip!
				assert_equal true, lh2.has_key?(member)
			end
		end
		
		def test_no_members
			lh = @cgo.hashify(@cga)
			assert_equal false, lh['placeholder'].has_key?('members')
		end
		
end