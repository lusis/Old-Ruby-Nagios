require 'libs/nagios/nagios'

class Nagjax
	
	def initialize(filename)
		datafile = '/tmp/nagdata.bin'
		nagios = Nagios.new
		if File.exists?(datafile) 
			latime = File.mtime(datafile)
			curtime = Time.now - 1400
			if curtime < latime
				@hosthash = Marshal.load(File.open(datafile))
			else
				Importer::new(filename)
				fh = File.open(datafile, 'w')
				marsh = Marshal.dump(nagios.detailedhosthash)
				fh.write marsh
				fh.close
				@hosthash = Marshal.load(File.open(datafile,'r'))
				fh.close
			end
		else
				Importer::new(filename)
				fh = File.open(datafile, 'w')
				marsh = Marshal.dump(nagios.detailedhosthash)
				fh.write marsh
				fh.close
				@hosthash = Marshal.load(File.open(datafile,'r'))
				fh.close
		end
	end
	
	def leftmenu()
		phash = @hosthash
		html = String.new
		hstnoservices = Array.new
		phash.keys.sort.each {|x| hstnoservices << x if phash[x][:services].empty?}
		html+= "<h3>Problem Hosts<a href=\"javascript:toggleLayer('problemHosts')\"> (#{hstnoservices.size}) </a></h3>
			<!-- Begin problemHosts div --><div id='problemHosts' style=\"display: none;\">
			<!-- Begin problemHosts_list div --><div class=\"menu\" id=\"problemHosts_list\">
			"
		hstnoservices.each {|y| 
					html += "
						<p><a onclick=\"markActive('#{y}_leftnav_problemhosts');\" id=\"#{y}_leftnav_problemhosts\" href=\"javascript:getDetails('#{y}')\">#{y}</a>
						"
				   }
		html += "</div><!-- End problemHosts_list div -->
			</div><!-- End problemHosts div -->
			"
		html += "<h3>All Hosts<a href=\"javascript:toggleLayer('allHosts')\"> (#{phash.keys.sort.size}) </a></h3>
			<!-- Begin allhosts div --><div id='allHosts' style=\"display: none;\">"
		phash.keys.sort.each do |hst|
			html += "
				<p><a href=\"javascript:getDetails('#{hst}')\">#{hst}</a> <a onclick=\"toggleState('#{hst}_leftnav');\" href=\"javascript:toggleLayer('#{hst}_services_leftmenu')\" id=\"#{hst}_leftnav\">(+)</a>
				"
			html += "
				<!-- begin #{hst}_services_leftmenu div --><div class=\"menu\" id=\"#{hst}_services_leftmenu\" style=\"display: none;\">
				"
			if phash[hst][:services].empty?
				html += "
					<p>No services!
					"
			else
				phash[hst][:services].keys.sort.each do |svc|
					html += "
						<p><a href=\"javascript:toggleLayer('center_#{hst}_#{svc.gsub(" ",'_')}_details')\">#{svc}</a>
						"
				end
			end
			html += "
				<!-- end #{hst}_services_leftmenu div --></div>
				"
		end
		html += "<!-- end allhosts div -->
			</div>
			"
		return html
	end

	def centerhtml(hst)
		centerhtml = String.new
		phash = @hosthash
		centerhtml = "
			<!-- 2 Begin #{hst}_centercontent div --><div id=\"#{hst}_centercontent\" class=\"host_centercontent\">
		"
		centerhtml += "
			<!-- 3 begin center_#{hst}_details div --><div class='menu' id='center_#{hst}_details'>
		"
		centerhtml += "
				<table>
				<tr><th colspan='2'>#{hst}</th></tr>
				<tr><td>Host Address:</td><td>#{phash[hst][:address]}</td></tr>
				<tr class='yellow'><td>Notification Period:</td><td>#{phash[hst][:notification_period]}</td></tr>
				<tr><td>Notification Options:</td><td>#{phash[hst][:notification_options]}</td></tr>
				<tr class='yellow'><td>Notification Interval:</td><td>#{phash[hst][:notification_interval]} minutes</td></tr>
				<tr><td>Parents:</td><td>#{phash[hst][:parents]}</td></tr>
				<tr class='yellow'><td>Template:</td><td>#{phash[hst][:use]}</td></tr>
				<tr><td colspan='2'>Services:</td></tr>
				</table>					
				"
		phash[hst][:services].keys.sort.each do |svc|
			centerhtml += "
				<!-- 4 begin center_#{hst}_#{svc.gsub(" ",'_')} div --><div class=\"submenu\" id='center_#{hst}_#{svc.gsub(" ",'_')}'>
						<p>#{svc}<a id=\"center_#{hst}_#{svc.gsub(" ",'_')}_details_nav\" onclick=\"toggleState('center_#{hst}_#{svc.gsub(" ",'_')}_details_nav');\" href=\"javascript:toggleLayer('center_#{hst}_#{svc.gsub(" ",'_')}_details')\">(+)</a></p>
						<!-- 5 begin center_#{hst}_#{svc.gsub(" ",'_')}_details div --><div id=\"center_#{hst}_#{svc.gsub(" ",'_')}_details\" class=\"servicedetails\" style=\"display: none;\">
						<table class='service-details'>
						<tr><td>Check Period:</td><td>#{phash[hst][:services][svc][:check_period]}</td></tr>
						<tr class='yellow'><td>Notification Options:</td><td>#{phash[hst][:services][svc][:notification_options]}</td></tr>
						<tr><td>Notification Period:</td><td>#{phash[hst][:services][svc][:notification_period]}</td></tr>
						<tr class='yellow'><td>Template:</td><td>#{phash[hst][:services][svc][:use]}</td></tr>
						<tr><td colspan='2'>Subscribers:</td></tr>
						</table>
						<!-- 6 begin centercontent_#{hst}_#{svc.gsub(" ",'_')}_contacts div --><div class=\"contact\" id=\"centercontent_#{hst}_#{svc.gsub(" ",'_')}_contacts\">
			"
			phash[hst][:services][svc][:subscribers].each_key do |subgrp|
				phash[hst][:services][svc][:subscribers][subgrp][:members].each do |sub,subdetails|
					if subdetails.has_key?(:pager) == false
						subdetails[:pager] = 'n/a'
					end
					centerhtml += "<p>#{subdetails[:alias]}<a id=\"centercontent_#{hst}_#{svc.gsub(" ",'_')}_#{subdetails[:alias].gsub(" ",'_')}_details_nav\" onclick=\"toggleState('centercontent_#{hst}_#{svc.gsub(" ",'_')}_#{subdetails[:alias].gsub(" ",'_')}_details_nav');\" href=\"javascript:toggleLayer('centercontent_#{hst}_#{svc.gsub(" ",'_')}_#{subdetails[:alias].gsub(" ",'_')}_details')\">(+)</a></p>
							<!-- 7 begin centercontent_#{hst}_#{svc.gsub(" ",'_')}_#{subdetails[:alias].gsub(" ",'_')}_details div --><div class=\"contactdetails\" id=\"centercontent_#{hst}_#{svc.gsub(" ",'_')}_#{subdetails[:alias].gsub(" ",'_')}_details\"  style=\"display: none;\">
							<table class='contact-details'>
							<tr><td>Email:</td><td>#{subdetails[:email]}</td></tr>
							<tr class='yellow'><td>Pager:</td><td>#{subdetails[:pager]}</td></tr>
							<tr><td>Host Period:</td><td>#{subdetails[:host_notification_period]}</td></tr>
							<tr class='yellow'><td>Host Options:</td><td>#{subdetails[:host_notification_options]}</td></tr>
							<tr><td>Service Period:</td><td>#{subdetails[:service_notification_period]}</td></tr>
							<tr class='yellow'><td>Service Options:</td><td>#{subdetails[:service_notification_options]}</td></tr>
							</table>
							</div><!-- 7 end centercontent_#{subdetails[:alias].gsub(" ",'_')}_details div -->
					"
				end
			end
			centerhtml += "
						<!-- 6 end centercontent_#{hst}_#{svc}_contacts div --></div>
					<!-- 5 end center_#{hst}_#{svc.gsub(" ",'_')}_details div --></div>
				<!-- 4 end center_#{hst}_services div --></div>
			"
		end
			centerhtml += "
					<!-- 3 end center_#{hst}_details div --></div>
				<!-- 2 end #{hst}_centercontent div --></div>
			<!-- 1 end centercontent div --></div>
			"
		return centerhtml
	end
end