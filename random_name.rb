#!/usr/bin/env ruby

require 'open-uri'

#I download the page once and after that query the temporary IO stream multiple
#times.
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


#Regex to grab Address
addr_str = site.chomp.match(/<div class="adr">\s+((\w+\s?)+?)<br\/>((\w+\s?)+?),\s(\w+)\s(\d+)\s+<\/div>/)
addr = {
  "Address" => addr_str[1],
  "City" => addr_str[3],
  "State" => addr_str[5],
  "Zip_Code" => addr_str[6]
}

#Regex to grab Phone #
phone_str = site.chomp.match(/\d{3}-\d{3}-\d{4}/)
ph_num = phone_str[0]

#Regex to grab Email
email_str = site.chomp.match(/>(\S+@[a-zA-Z_]+?\.[a-zA-Z]{2,6})/)
email = email_str[1]

#Regex to grab SSN.
#ssn_str = site.chomp.match(/<li class="lab">SSN:<\/li><li>(\d{3}-\d{2}-\d{4})\s?<div class/)
ssn_str = site.chomp.match(/\d{3}-\d{2}-\d{4}/)
ssn = ssn_str[0]

#Passport generation
passport = ((0..899999).to_a.sample)+1000000

#Issue Date generation
issue_date = "#{mob}/#{Date.today.year-2}"
expire_date = "#{mob}/#{Date.today.year+2}"

# Presentation
print result =
"First Name:  #{firstname}
Last Name:   #{lastname}
Birthdate:   #{bdate}
Address:     #{addr["Address"]}
City:        #{addr["City"]}
State:       #{addr["State"]}
Zip Code:    #{addr["Zip_Code"]}
Phone:       #{ph_num}
Email:       #{email}
SS Number:   #{ssn}
Passport:    #{passport}
Issue Date:  #{issue_date}
Expire Date: #{expire_date}
"