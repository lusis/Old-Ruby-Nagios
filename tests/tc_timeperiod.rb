require 'test/unit'
require 'libs/nagios/timeperiod.rb'

class TestTimeperiod < Test::Unit::TestCase

  def setup
	tph = Hash.new
	tph2 = Hash.new
	
	tph = {"monday"		=> "00:00-24:00",
		"tuesday"			=> "00:00-24:00",
		"wednesday"			=> "00:00-24:00",
		"thursday"			=> "00:00-24:00",
		"friday"			=> "00:00-24:00",
		"saturday"			=> "00:00-24:00",
		"sunday"			=> "00:00-24:00",
		"alias"				=> "24 Hours/Day, 7 Days/Week",
		"timeperiod_name"	=> "24x7"
		}
	
	tph2 = {"business_hours"	=> {"ranges"	=> {"monday"				=> "09:00-18:00",
												  "tuesday"					=> "09:00-18:00",
												  "wednesday"				=> "09:00-18:00",
												  "thursday"				=> "09:00-18:00",
												  "friday"					=> "09:00-18:00"},
									"timeperiod_alias"	=> "Weekday Business Hours"
									}
	}
	@tpo = Timeperiod.new
	@tpo.import(tph)
	@tpo.add(tph2)
  end
	
  def test_import
	assert_instance_of Hash, @tpo.list['24x7']
  end
  
  def test_add
	assert_instance_of Hash, @tpo.list['business_hours']
  end
  
  def teardown
	Timeperiod.class_eval { class_variable_set :@@timeperiods, Hash.new }
  end
  
  def test_merge
	%w[business_hours 24x7].each {|x| assert true, @tpo.list.has_key?(x)}
  end
  
  def test_name
    assert true, @tpo.list.has_key?('24x7')
    assert true, @tpo.list.has_key?('business_hours')
  end
  
  def test_alias
    assert_equal '24 Hours/Day, 7 Days/Week', @tpo.list['24x7']['timeperiod_alias']
    assert_equal 'Weekday Business Hours', @tpo.list['business_hours']['timeperiod_alias']
  end

  def test_ranges
    assert_instance_of Hash, @tpo.list['24x7']['ranges']
    assert_instance_of Hash, @tpo.list['business_hours']['ranges']
  end

  def test_ranges_count
    assert_equal 7, @tpo.list['24x7']['ranges'].length
    assert_equal 5, @tpo.list['business_hours']['ranges'].length
  end

  def test_ranges_time
    @tpo.list['24x7']['ranges'].each do |k,v|
      assert_equal '00:00-24:00', v
    end
    @tpo.list['business_hours']['ranges'].each do |k,v|
      assert_equal '09:00-18:00', v
    end
  end

  def test_duplicate
	ltph = {"monday"		=> "00:00-24:00",
		"tuesday"			=> "00:00-24:00",
		"wednesday"			=> "00:00-24:00",
		"thursday"			=> "00:00-24:00",
		"friday"			=> "00:00-24:00",
		"saturday"			=> "00:00-24:00",
		"sunday"			=> "00:00-24:00",
		"alias"				=> "24 Hours/Day, 7 Days/Week",
		"timeperiod_name"	=> "24x7"
		}
	ltph2 = {"business_hours"	=> {"ranges"	=> {"monday"				=> "09:00-18:00",
												  "tuesday"					=> "09:00-18:00",
												  "wednesday"				=> "09:00-18:00",
												  "thursday"				=> "09:00-18:00",
												  "friday"					=> "09:00-18:00"},
									"timeperiod_alias"	=> "Weekday Business Hours"
									}
	}
	assert_raise RuntimeError do
	  @tpo.import(ltph)
	end
	assert_raise RuntimeError do
	  @tpo.add(ltph2)
	end
  end
  
  def test_nil
	  ltph = {"monday"	=> "00:00-24:00",
		"tuesday"			=> "00:00-24:00",
		"wednesday"			=> "00:00-24:00",
		"thursday"			=> "00:00-24:00",
		"friday"			=> "00:00-24:00",
		"saturday"			=> "00:00-24:00",
		"sunday"			=> "00:00-24:00",
		"timeperiod_name"	=> "7x24"
		}
	  ltph2 = {"business_hours2"	=> {"ranges"	=> {"monday"				=> "09:00-18:00",
												  "tuesday"					=> "09:00-18:00",
												  "wednesday"				=> "09:00-18:00",
												  "thursday"				=> "09:00-18:00",
												  "friday"					=> "09:00-18:00"}
									}
	  }
	  assert_raise ArgumentError do
		@tpo.import(ltph)
	  end
	  assert_raise ArgumentError do
		@tpo.add(ltph2)
	  end	  
  end
 
  
end
