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
require 'set'

a = ARGV[0]
b = ARGV[1]
outfile = ARGV[2]
operation = ARGV[3]
logfile = File.new("logfile.txt", "w")

def get_001(rec)
  m001s = rec.find_all {|field| field.tag == '001'}
  if m001s.size > 1 || m001s.size == 0
    return "err"
  else
    return m001s[0].value
  end
end

def build_001_set(mrcfile, setname)
  puts "\nExtracting 001 values from #{mrcfile}..."
  warnings = []
  rec_ct = 0
  MARC::Reader.new(mrcfile).each do |rec|
    rec_ct += 1
    the001 = get_001(rec)
    if the001 == "err"
      warnings << "WARNING: Record number #{rec_ct} in #{mrcfile} does NOT have one 001 field. Results do not include this record!"
    else
      the001.sub!(/\s*oc?[mn](\d+)[^0-9]*/, '\1')
      set_size_before = setname.size
      setname.add(the001)
      set_size_after = setname.size
      if set_size_before == set_size_after
        warnings << "WARNING: More than one record in #{mrcfile} has the 001 value #{the001}. Check #{mrcfile} for duplicate records."
      end
    end
  end
  unless rec_ct == setname.size
    warnings.each {|msg| logfile.puts msg}
    abort "\n\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\nERROR IN INPUT FILE(S) -- SCRIPT STOPPED EARLY\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\nCheck #{mrcfile} for problems related to number of 001s included and/or duplicate records.\nSee logfile.txt for details.\n"
  end
  puts "#{setname.size} recs in #{mrcfile}."
end

# Build sets of the 001 values from records in both files
# Will be used to determine which records from file a to write to final output file.
a001s = Set.new
build_001_set(a, a001s)

b001s = Set.new
build_001_set(b, b001s)

writer = MARC::Writer.new(outfile)

# Build set of 019s from file b -- any file a records with 001 that matches a value
#   in this set should NOT be written out. It is being replaced by the record in file b
# This loop through file b also writes all the records from that file to output, since we
#   know we need keep all the fresher/update records from b

puts "\nExtracting 019s from #{b} and writing out all updated records..."
b019s = Set.new
bh = {}
MARC::Reader.new(b).each do |rec|
  ct_019s = rec.fields('019').count
  if ct_019s > 1
    abort "\n\n -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= \nERROR IN #{b} -- SCRIPT STOPPED EARLY\n -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= \nA record has more than one 019 field\n"
  end
  unless ct_019s == 0
    the001 = rec['001'].value.sub!(/\s*oc?[mn](\d+)[^0-9]*/, '\1')
    rec['019'].find_all {|sf| sf.code == 'a'}.each do |val|
      b019s.add(val.value)
      bh[val.value] = the001
    end
  end
    writer.write(rec) unless operation == "d"
end

a_to_write = a001s - b001s - b019s

puts "#{a_to_write.size} record(s) retained from #{a}"
ov_on_001 = a001s.intersection(b001s)
puts "#{ov_on_001.size} record(s) from #{a} overlaid with records from #{b} on 001"
ov_on_019 = a001s.intersection(b019s)
puts "#{ov_on_019.size} record(s) from #{a} overlaid with records from #{b} on 019"

ov_019_001s_from_b = Set.new
ov_on_019.each do |v019|
  ov_019_001s_from_b.add(bh[v019])
end

new_in_b = b001s - ov_on_001 - ov_019_001s_from_b
puts "#{new_in_b.size} records NEW from #{b}. See logfile.txt for details."
new_in_b.each {|v| logfile.puts "New record in b: #{v}"}

puts "\nWriting out records to be kept from #{a}..."
MARC::Reader.new(a).each do |rec|
  the001 = rec['001'].value
  the001.sub!(/\s*oc?[mn](\d+)[^0-9]*/, '\1')
  if a_to_write.include?(the001)
    writer.write(rec)
  end
end

writer.close

written_ct = a_to_write.size
written_ct += b001s.size unless operation == "d"

puts "\n#{written_ct} records written to #{outfile}."
