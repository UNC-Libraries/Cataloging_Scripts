# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# PURPOSE: Creates a file containing the MARC records that exist in BOTH input files
# USAGE:
#  ruby find_recs_in_both_files.rb inputfilea inputfileb outputfile
#  - all input and output files must be raw MARC (.mrc, .dat, etc.) files
#  - comparison is based on value of 001 field---it does not compare entire records against one another
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

require 'rubygems'
require 'marc'
require 'set'

a = ARGV[0]
b = ARGV[1]
out = ARGV[2]

ra = []
rb = []

puts "Reading in records from #{a}..."
a_ct = 0
MARC::Reader.new(a).each do |rec|
  a_ct += 1
  m001s = rec.find_all {|field| field.tag == '001'}
  if m001s.size > 1
    puts "#{a} contains record with more than 1 001, including #{m001s[0].value}. Results do not include this record!"
  elsif m001s.size == 0
    puts "#{a} contains record with NO 001 field. Results do not include this record!"
  else
    ra << m001s[0].value
  end
end #MARC::Reader.new(a).each do
puts "#{a_ct} records in #{a}."

puts "Reading in records from #{b}..."
b_ct = 0
MARC::Reader.new(b).each do |rec|
  b_ct += 1
  m001s = rec.find_all {|field| field.tag == '001'}
  if m001s.size > 1
    puts "#{b} contains record with more than 1 001, including #{m001s[0].value}. Results do not include this record!"
  elsif m001s.size == 0
    puts "#{b} contains record with NO 001 field. Results do not include this record!"
  else
    rb << m001s[0].value
  end
end #MARC::Reader.new(b).each do |rec|
puts "#{b_ct} records in #{b}."

rintersect = ra & rb

puts "Number of records in both files: #{rintersect.size}"

if rintersect.size > 0
  wrecs = []
  MARC::Reader.new(a).each do |rec|
    the001 = rec['001'].value
    wrecs << rec if rintersect.include?(the001)
  end #MARC::Reader.new(a).each do |rec|

  writer = MARC::Writer.new(out)
  wrecs.each {|rec| writer.write(rec)}
  writer.close
end
