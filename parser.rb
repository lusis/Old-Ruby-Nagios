#!/usr/bin/env ruby
require 'getoptlong'
require 'libs/nagios/nagios'
require 'pp'


nagiosconfig = "#{ENV['HOME']}/nagios/nagios2.cfg"
yamlout = "#{ENV['HOME']}/dev-output/"
nagios_object = "contact"

opts = GetoptLong.new(
        ["--cfgfile", "-c", GetoptLong::OPTIONAL_ARGUMENT],
        ["--output", "-d", GetoptLong::OPTIONAL_ARGUMENT],
		["--object", "-o", GetoptLong::OPTIONAL_ARGUMENT]
)

opts.each do |opt,arg|
        case opt
                when "--cfgfile"
                        nagiosconfig = arg
                when "--output"
                        yamlout = arg
				when "--object"
						nagios_object = arg
        end
end



myimporter = Importer.new(nagiosconfig)
pp myimporter.get_all_objects_of_type(nagios_object)

