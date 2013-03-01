#!/usr/bin/env ruby

require 'open-uri'

#Opens IO stream.
randsite = open("http://www.fakenamegenerator.com/gen-random-us-us.php", "r")
#Sets empty string to allow html to be injected in.
site = ""
#Iterates through each line injected the string with html.
randsite.each do |line|
  site << line
end
#Closes IO stream.
randsite.close

#Regex to find First and Last name.
name = site.chomp.match(/<div class="address">\n\s+<h3>(\w+)\s\w?\W?\s+?(\w+)<\/h3>\s+/)
firstname = name[1]
lastname = name[2]

#Hash to translate Month names to integers.
months = {
  "January" => 1,
  "February" => 2,
  "March" => 3,
  "April" => 4,
  "May" => 5,
  "June" => 6,
  "July" => 7,
  "August" => 8,
  "September" => 9,
  "October" => 10,
  "November" => 11,
  "December" => 12
}

#Regex to grab Month, Day, and Year of birth.
birthinfo = site.chomp.match(/<li class="bday">(\w+) (\d{1,2}), (\d{4}) \(\d{1,3} years? old\)<\/li><br\/>/)

mob = months[birthinfo[1]]
dob = birthinfo[2]
yob = birthinfo[3]

bdate = "#{mob}/#{dob}/#{yob}"

#Regex to grab SSN.
ssn_str = site.chomp.match(/<li class="lab">SSN:<\/li><li>(\d{3}-\d{2}-\d{4})\s?<div class/)
ssn = ssn_str[1]

