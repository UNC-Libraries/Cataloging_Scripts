# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# PURPOSE: Takes 2 files (a and b) as input. Creates a new file containing the MARC records from file a, that are not also in file b. Put another way: creates a new file containing the unique records from file a.

# USAGE:
#  ruby find_a_minus_b.rb inputfilea inputfileb outputfile
#  - all input and output files must be raw MARC (.mrc, .dat, etc.) files
#  - comparison is based on value of 001 field---it does not compare entire records against one another

# Tested with Ruby version 2.0.0
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

require 'marc'

a = ARGV[0]
b = ARGV[1]
outfile = ARGV[2]

# Get 001 values from file b
b001s = []
puts "Getting 001 values from #{b}..."
MARC::Reader.new(b).each do |rec|
  m001s = rec.find_all {|field| field.tag == '001'}
  if m001s.size > 1
    puts "#{b} contains record with more than 1 001, including #{m001s[0].value}. Results do not include this record!"
  elsif m001s.size == 0
    puts "#{b} contains record with NO 001 field. Results do not include this record!"
  else
    the001 = m001s[0].value.gsub!(/\s*oc?[mn](\d+)[^0-9]*/, '\1')
    b001s << the001
  end
end #MARC::Reader.new(b).each do |rec|
puts "#{b001s.size} 001s in #{b}"
#b001s.each {|v| puts v}

writer = MARC::Writer.new(outfile)

# Go through records in file a, writing each to outfile unless its 001 was in file b
puts "Examining records from #{a}..."
all_ct = 0
keeper_ct = 0
MARC::Reader.new(a).each do |rec|
  all_ct += 1
  m001s = rec.find_all {|field| field.tag == '001'}
  if m001s.size > 1
    puts "#{a} contains record with more than 1 001, including #{m001s[0].value}. Results do not include this record!"
  elsif m001s.size == 0
    puts "#{a} contains record with NO 001 field. Results do not include this record!"
  else
    the001 = m001s[0].value
    the001.gsub!(/\s*oc?[mn](\d+)[^0-9]*/, '\1')
 #   puts the001
    unless b001s.include?(the001)
      writer.write(rec)
      keeper_ct += 1
    end
  end
end #MARC::Reader.new(a).each do |rec|
puts "\n\nDONE!\n#{all_ct} records in #{a}.\n#{keeper_ct} records kept.\n"

writer.close
