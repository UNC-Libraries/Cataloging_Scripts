# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# PURPOSE: Takes 2 files (a and b) as input.
# Creates a new file containing:
# - all records from a that do not appear in b
# - all records from b that do not appear in a
# - the b version of any records that appear in both b and a

# Put another way, creates merged/updated version of a, using b as the "update file" 

# USAGE:
#  ruby update_a_with_b.rb inputfilea inputfileb outputfile
#  - all input and output files must be raw MARC (.mrc, .dat, etc.) files
#  - comparison is based on value of 001 field---it does not compare entire records against one another

# Tested with Ruby version 2.0.0
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

require 'marc'

a = ARGV[0]
b = ARGV[1]
outfile = ARGV[2]

rec_hash = {}

def get_001(rec)
  m001s = rec.find_all {|field| field.tag == '001'}
  if m001s.size > 1 || m001s.size == 0
    return "err"
  else
    return m001s[0].value
  end
end

puts "Getting records from #{a}..."
a_ct = 0
a_err_ct = 0
a_ok_ct = 0
MARC::Reader.new(a).each do |rec|
  a_ct += 1
  the001 = get_001(rec)
  if the001 == "err"
    puts "Record number #{a_ct} in #{a} does NOT have one 001 field. Results do not include this record!"
    a_err_ct += 1
  else
    rec_hash[the001] = rec
    a_ok_ct += 1
  end
end

puts "Getting records from #{b}..."
b_ct = 0
b_err_ct = 0
b_new_ct = 0
ov_ct = 0 #count of records in a that are also in b

MARC::Reader.new(b).each do |rec|
  b_ct += 1
  the001 = get_001(rec)
  if the001 == "err"
    puts "Record number #{b_ct} in #{b} does NOT have one 001 field. Results do not include this record!"
    b_err_ct += 1
  else
    if rec_hash.has_key?(the001)
      ov_ct += 1
    else
      b_new_ct += 1
    end
    rec_hash[the001] = rec
  end
end 


 
puts "#{a_ct} records in #{a}, with #{a_err_ct} abnormal 001s."
puts "#{b_ct} records in #{b}, with #{b_err_ct} abnormal 001s."
puts "#{ov_ct} records from #{a} overlaid by records from #{b}."
puts "#{b_new_ct} new records added from #{b}."
puts "Writing #{rec_hash.size} total records to #{outfile}..."

writer = MARC::Writer.new(outfile)
rec_hash.each_value {|rec| writer.write(rec)}
writer.close

puts "#{outfile} written successfully. Done!"
