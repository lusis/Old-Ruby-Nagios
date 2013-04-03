require 'test/unit'
require 'libs/nagios/command.rb'

class TestCommand < Test::Unit::TestCase
	def setup
		@command_array = []
		@command_array << {"command_name"=>"check-host-alive",
				"command_line"=>"$USER1$/check_ping -H $HOSTADDRESS$ -w 3000.0,80% -c 5000.0,100% -p 5"}
		@command_array << {"command_name"=>"check_local_disk",
				"command_line"=>"$USER1$/check_disk -w $ARG1$ -c $ARG2$ -p $ARG3$"}
		@command_array << {"command_name"=>"check_local_load",
				"command_line"=>"$USER1$/check_load -w $ARG1$ -c $ARG2$"}
	@command_object = Command.new
	end
	
	def test_hashify
		lh = @command_object.hashify(@command_array)
		assert_instance_of Hash, lh
	end
	
	def test_name
		lh = @command_object.hashify(@command_array)
		assert lh.has_key?('check-host-alive')
		assert lh.has_key?('check_local_disk')
		assert lh.has_key?('check_local_load')
	end
	
	def test_counts
		   lh = @command_object.hashify(@command_array)
		   assert_equal 3, lh.length
	end
	
	def test_commands
		  lh = @command_object.hashify(@command_array)
		  assert_equal "$USER1$/check_ping -H $HOSTADDRESS$ -w 3000.0,80% -c 5000.0,100% -p 5", lh['check-host-alive']['command_line']
		  assert_equal "$USER1$/check_disk -w $ARG1$ -c $ARG2$ -p $ARG3$", lh['check_local_disk']['command_line']
		  assert_equal "$USER1$/check_load -w $ARG1$ -c $ARG2$", lh['check_local_load']['command_line']
	end
end
