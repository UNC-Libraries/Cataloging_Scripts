# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# PURPOSE: select from full OHO MARC file only those records that:
#  - are not already in the catalog (based on 001 value); OR
#  - have been updated since we last loaded them (based on 005 value)

# USAGE:
#  ruby oho_preprocess.rb name_of_mrc_file.mrc
#  - Input files (in OHO - Oxford Handbooks Online\processing directory):
#    - raw MARC (.mrc) file of all records for content our institution has access to
#    - ilsdata.txt - exported 001 and 005 values for OHO records currently in catalog

# Production copy of script lives at:
# \\ad.unc.edu\lib\departments\TechServ\ESM\e-resources cataloging\E-book record loads\OHO - Oxford Handbooks Online\processing

# Tested with Ruby version 2.3.0
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

require 'marc'

fullmrc = ARGV[0]
to_report = []
outfilename = fullmrc.gsub(/\.mrc/, '') + '_to_prep.mrc'
marcout = MARC::Writer.new(outfilename)

#{ 001val => ['005val', '005val'] }
ilsdata = {}
ilsct = -1 #account for header line that we are not specifically removing
# Throw 001 and 005 values into hash
File.open('ilsdata.txt', 'r').each_line { |ln|
  ilsct += 1
  ln.chomp!
  f = ln.split(/\t/)
  if ilsdata.has_key?(f[0])
    ilsdata[f[0]] << f[1]
  else
    ilsdata[f[0]] = [f[1]]
  end
}

puts "Recs in ILS: #{ilsct}"

# Keep only last update date for any duplicate records
ilsdata.each_pair { |k, v|
  vsize = v.size
  if vsize > 1
    v.sort!
    v.shift(vsize - 1)
    to_report << "#{k},duplicate records in ILS\n"
  end
}

overlays = 0
inserts = 0

new_rec_ct = 0
new_001s = []
MARC::Reader.new(fullmrc).each { |rec|
  new_rec_ct += 1
  this001 = rec['001'].value
  new_001s << this001
  this005 = rec['005'].value
  if ilsdata.has_key?(this001)
    last005 = ilsdata[this001][0]
    if this005 > last005
      #rec.append(MARC::DataField.new('999', ' ', ' ', ['a', 'overlay']))
      marcout.write(rec)
      overlays += 1
    end
  else
    marcout.write(rec)
    inserts += 1
  end
}

marcout.close

puts "Expected inserted records: #{inserts}"
puts "Expected overlaid records: #{overlays}"

new_001s.uniq!

if new_001s.size != new_rec_ct
  to_report << "na, check file retrieved from OUP for recs with duplicate 001s"
end

if to_report.size > 0
  report = File.open('report.csv', 'w')
  to_report.each { |ln| report.puts ln }
  report.close
end
