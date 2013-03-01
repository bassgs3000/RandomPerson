#!/usr/bin/perl

use strict;

############################################################
# Paul Allen - 01March2013 - Insight Card Services
# random_names.pl - Version 1
# This script was written to create random, valid personal info to use when ordering and issuing new cards in Phase2.
# Version 2 of this script will have the option to either display the info for manual entry via Phase2 GUI, or hitting the API
# directly to quickly & easily order & issue cards.

############################################################
# Declare variables:
my(@rand_info,@person,$fname,$lname,$month,$day,$year,$dob,$address,$city,$state,$zip,$phone,$email,$passport,$issue_date,$expire_date);
############################################################
# Populate variables:
my $line_count = 1;
$passport = int(rand(899999)) + 1000000;
my $current_year = `date +%G`;
chomp($current_year);
my $iss_year = $current_year - 2;
my $exp_year = $current_year + 2;

# Build the social security #, passport #, issue year, & expire year:
#$ss1 = int(rand(899)) + 100; $ss2 = int(rand(89)) + 10; $ss3 = int(rand(8999)) + 1000; $ss = $ss1 . "-" . $ss2 . "-" . $ss3;
# I was building the SSN, but kept getting instances where it wasn't a valid one, so rather than doing anything complex like adding modules,
# I decided to just cURL http://www.fakenamegenerator.com/social-security-number.php which always returns a random, valid SSN.
my $ssn = `curl -s http://www.fakenamegenerator.com/social-security-number.php|grep Random`;
# Create a random passport number:
$ssn =~ s/\<p\>\<strong\>Random SSN\:\<\/strong\>\s*(\d{3}\-\d{2}\-\d{4})\<\/p\>/$1/g;
chomp($ssn);
# cURL an actual, random postal address:
my @real_us = `curl -s http://realusaaddress.com`;

foreach my $line (@real_us) {
	chomp($line);
	# Only look at lines between 145 - 148:
	if ($line_count < 145) { $line_count++; next }
	# For some reason, the phone number line occasionally shifts to contain google_ad_client info, so reset count & restart loop if that happens:
	if ($line =~ /google_ad_client/) { $line_count = 1; redo; }
	# Strip out newlines, carriage returns, multiple whitespaces, HTML tags, trailing whitespaces, etc
	$line =~ s/[\n\r]|\s{2,}|\<.*?\>|\<.*?$|\s+$|\(\D+\)//g;
	if (!$line) { next }
	# Instead of compiling all info here, push each line into an array & compile later so that the order of output can be changed:
	push(@person, $line);
	$line_count++;
	# Only look at lines between 145 - 148:
	if ($line_count > 148) { last }
}
# Reset the line count for the next loop:
$line_count = 1;
# Loop through the array created above & set variables according to conditions
foreach my $line (@person) {
	if ($line_count eq 1) { if ($line =~ /^(\w+)\s(\w+)/){ $fname = $1; $lname = $2 } }
	if ($line_count eq 2) { $address = $line }
	if ($line =~ /(\w+),\s(\w+)\s(\d{5})\-\d{4}/) { $city = $1; $state = $2; $zip = $3 }
	if ($line =~ /(\(\d{3}\)\s\d{3}\-\d{4})/) { $phone = $1; $phone =~ s/\(|\)//g; $phone =~ s/ /-/g; }
	$line_count++;
}
# This was the simplest way to get a random, valid birthday without installing extra modules or doing a lot of extra scripting:
my $rand_info = `curl -s http://igorbass.com/rand/|head -n8`;
if ($rand_info =~ /(\d+)\/(\d+)\/(\d{4})\s\(.*?$/sg) {
	$month = $1;
	$day = $2;
	$year = $3;
	$dob = sprintf("%02d", $1) . "/" . sprintf("%02d", $2) . "/" . $3;
	$issue_date = sprintf("%02d", $1) . "/" . sprintf("%02d", $2);
	$expire_date = sprintf("%02d", $1) . "/" . sprintf("%02d", $2-1);
}
# Compile the email address, passport issue date, and expiration date
$email = lc(substr($fname, 0, 1)) . lc($lname) . "\@notgmail.com";
$issue_date = $issue_date  . "/" . $iss_year;
$expire_date = $expire_date . "/" . $exp_year;

############################################################
# NOTE: The order of input fields for which we need random info in Phase2 GUI are:
#	First Name, MI, Last Name, Birthdate,
#	Address1, Address2, City, State, Postal Code,
#	Mobile Phone, Home Phone, Email,
#	ID Type (SSN), ID Number
#	Photo ID type (Passport), ID Number, Issue Date, Expiration Date

# Print the output variables
print "
First Name:	$fname
Last Name:	$lname
Birthdate:	$dob
Address:	$address
City:		$city
State:		$state
Zip Code:	$zip
Phone:		$phone
Email:		$email
SS Number:	$ssn
Passport:	$passport
Issue Date:	$issue_date
Expire Date:	$expire_date
\n";
