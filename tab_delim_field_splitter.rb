# Used when one field in a tab delimited file has multiple values squished 
# into it and you want one line per value. 
# Example: URL checker data exported from Millennium review file. Multiple 
# 856|u will be in output from Millennium. This script will create a new line 
# for each 856|u, duplicating all other field data for each 856|u. 

# Instructions: 
# Export .txt file from Millennium with TAB delimiter between fields, ; as 
# delimiter for repeated values within fields, and " as text qualifier. 
# 
# The field expected to contain multiple values should be the last field 
# exported. 
# 
# Run script. Output file will be located at: 
#  output/split_fields.csv

require 'rubygems'
require 'csv'

file = ARGV[0]

lines = IO.readlines(file)

lines.each do |l|
  #puts l
  l.gsub! /"/, ''
  l.chomp!
  #puts l
  #puts "\n"
end

#Grab headers, break up meaningfully, and hash for later use
headers = lines.shift.split(/\t/)

to_split_index = headers.count - 1

line_hash = {}

lines.each do |l|
  line = l.split(/\t/)
  other_fields = line.shift(to_split_index)
  field_to_split = line.shift

  if field_to_split
   splits = field_to_split.split(";")
  else
    splits = ['']
  end

  line_hash[other_fields] = splits
end

lines_to_write = []

line_hash.each_pair {|k, v|
 v.each do |val|
   newline = []
   #puts "val = #{val.inspect.to_s}"
   #puts "k = #{k.inspect.to_s}"
   newline << k
   newline << val
   lines_to_write << newline.flatten!
   #p newline
 end
# puts "\n"
}

CSV.open "output/split_fields.csv", "wb" do |csv|
  csv << headers
  lines_to_write.each {|ln| csv << ln}
end
  
