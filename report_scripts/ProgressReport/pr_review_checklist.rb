#
# Converts the Progress Report Review Checklist from CSV to two formats -
#  - Pipe delimited (with ‘|’ instead of commas, and ‘||’ instead of carriage returns)
#  - XML (example)
#
# <Grant_Info>
#   <RFA_Num>06-02: Comprehensive</RFA_Num>
#  <Application_Number>06-02: Comprehensive</ Application_Number>
# </ Grant_Info >

# Author: Bhanu Morampudi (bhanu@cirm.ca.gov)
# Date: November 02, 2009
#
# Input is a CSV file (saved in the Windows CSV format).
# Run this from irb
#

require 'csv'
require 'builder'

def convert_to_pipe(fn)

	csv = CSV::Reader.parse(File.read(fn))

  new_row = ""

	csv.each do |row|
    puts "________________________________________"
    puts "Processing row: #{row.inspect}"

    # rfa = row[0]
    rfa, rfa_name = row[0].split(':')
    grant_number = row[1]
    from_date = row[2]
    to_date = row[3]
    institution = row[4]
    first_name = row[5]
    last_name = row[6]

    pipe = "|"

    new_row = new_row + rfa + pipe + rfa_name.strip + pipe + grant_number + pipe +
              from_date + pipe + to_date + pipe + institution + pipe +
              first_name + pipe + last_name + pipe + pipe

  end

  f = File.new("pr_review_checklist.pipe", "w")
  f.puts new_row
  f.close

  puts ""
  puts "Output created in file: 'pr_review_checklist.pipe'"

end

def convert_to_xml(fn)

	csv = CSV::Reader.parse(File.read(fn))

  xml = Builder::XmlMarkup.new(:indent => 2 )

  xml.instruct! :xml, :version => "1.0", :encoding => "US-ASCII"

  xml.grant_data do

    csv.each do |row|

      # puts "________________________________________"
      # puts "row: #{row.inspect}"

      rfa, rfa_name = row[0].split(':')
      grant_number = row[1]
      from_date = row[2]
      to_date = row[3]
      institution = row[4]
      first_name = row[5]
      last_name = row[6]

      xml.grant_info do 

        xml.rfa_num rfa
        xml.rfa_name rfa_name.strip
        xml.application_number grant_number
        xml.from_date from_date
        xml.to_date to_date
        xml.institution institution
        xml.first_name first_name
        xml.last_name last_name

      end
      
    end

  end

  f = File.new("pr_review_checklist.xml", "w")
  f<< xml
  f.close

  puts ""
  puts "Output created in file: 'pr_review_checklist.xml'"

end
