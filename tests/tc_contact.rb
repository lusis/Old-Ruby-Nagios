require 'test/unit'
require 'libs/nagios/contact.rb'

class TestContact < Test::Unit::TestCase
  def setup
    @contact_array = []
    @contact_array << {"service_notification_period"=>"24x7",
                      "host_notification_options"=>"d,u,r",
                      "service_notification_commands"=>"notify-service-by-email",
                      "host_notification_period"=>"24x7",
                      "host_notification_commands"=>"notify-host-by-email",
                      "service_notification_options"=>"w,u,c,r",
                      "alias"=>"John E. Vincent",
                      "email"=>"root@localhost",
                      "contact_name"=>"johnv"
    }
    @contact_object = Contact.new
  end

  def test_hashify
    lh = @contact_object.hashify(@contact_array)
    assert_instance_of Hash, lh
  end
  
  def test_contact_name
    lh = @contact_object.hashify(@contact_array)
    assert lh.has_key?('johnv')
  end
  
  def test_email
    lh = @contact_object.hashify(@contact_array)
    assert_equal 'root@localhost', lh['johnv']['email']
  end
  
  def test_alias
    lh = @contact_object.hashify(@contact_array)
    assert_equal 'John E. Vincent', lh['johnv']['contact_alias']
  end
  
  def test_snp
    lh = @contact_object.hashify(@contact_array)
    assert_equal '24x7', lh['johnv']['service_notification_period']
  end
  
  def test_hnp
    lh = @contact_object.hashify(@contact_array)
    assert_equal '24x7', lh['johnv']['host_notification_period']
  end
  
  def test_sno
    lh = @contact_object.hashify(@contact_array)
    assert_equal 'w,u,c,r', lh['johnv']['service_notification_options']
  end

  def test_hno
    lh = @contact_object.hashify(@contact_array)
    assert_equal 'd,u,r', lh['johnv']['host_notification_options']
  end

end
