#!/usr/bin/env ruby
=begin
Create changelog for upgrading Ubuntu Linux (will probably work on Debian too).

Author : Jonas Björk <jonas.bjork@me.com>
Date   : 2014
License: GNU General Public License, version 2
		  http://www.gnu.org/licenses/gpl-2.0.html

Usage:

This script will create a changelog from two files:
before.csv and after.csv which has been created from the 
following command:
	dpkg -l | grep ^ii | awk '{print $2 "," $3}' > before.csv

Before you are upgrading the Ubuntu operating system you create 
the `before.csv` file:

	dpkg -l | grep ^ii | awk '{print $2 "," $3}' > before.csv

Then you upgrade the operating system with the normal `apt-get` 
commands, and then you create the `after.csv` file:

	dpkg -l | grep ^ii | awk '{print $2 "," $3}' > after.csv

With both csv files in the same folder as `changelog.rb` you run 
the script:

	ruby changelog.rb 

Output is difference between packages installed before, and after, 
the upgrade.

=end

before = 'before.csv'
after = 'after.csv'

blist = Hash.new
alist = Hash.new
uninstalled = Hash.new
installed = Hash.new

f = File.open(before, "r")

f.each_line { |line|

  fields = line.split(',')
  key = fields[0].tr_s('"', '').strip
  value = fields[1].tr_s('"', '').strip

  blist[key] = value
}

f.close

f = File.open(after, "r")

f.each_line { |line|

  fields = line.split(',')
  key = fields[0].tr_s('"', '').strip
  value = fields[1].tr_s('"', '').strip

  alist[key] = value
}

f.close



puts "\n== Upgraded packages =="

blist.each do |b|

	key = b[0]
	value = b[1]

	if value != alist[key] then

		nversion = (alist[key] or "Uninstalled")

		if nversion == "Uninstalled" then
			uninstalled[key] = value
		else
			str = key.ljust(30, ' ') + value.ljust(30, ' ') + nversion
			puts str
		end
	end

end

if uninstalled.count > 0 then

	puts "\n== Uninstalled packages =="
	uninstalled.each do |u|
		puts u[0].ljust(30, ' ') + u[1].ljust(30, ' ')
	end
end

alist.each do |a| 

	oldpackage = (blist[a[0]] or "Installed")

	if oldpackage == "Installed" then
		installed[a[0]] = a[1]
	end

end

if installed.count > 0 then
	puts "\n== Installed packages =="
	installed.each do |i|
		puts i[0].ljust(30, ' ') + i[1].ljust(30, ' ')
	end
end

