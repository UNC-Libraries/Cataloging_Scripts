# Used on .mrc files where records have duplicate 001 values
# Looks at the 005 date/time of each record with the same 001 value
# Keeps the record with the most recent 005 value

# coding: utf-8
# ruby 2.3
# runs on .mrc file
# usage:
# ruby keep_most_recent_001_dupe.rb path-to-mrc-file.mrc output-path.mrc

require "marc"

#  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#    SCRIPT INPUT
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Incoming MARC records
mrcfile = ARGV[0]

unless File.exist?(mrcfile)
  puts "\n\nERROR: #{mrcfile} is missing. Please check file names and run script again.\n\n"
  exit
end

marcwriter = MARC::Writer.new(ARGV[1])

recs_by_001 = {}

reader = MARC::Reader.new(mrcfile)
for rec in reader
  the001 = rec['001'].value
  if recs_by_001[the001]
    recs_by_001[the001] << rec
  else
    recs_by_001[the001] = [rec]
  end
end

recs_by_001.each_pair do | the001, rec_array |
  if rec_array.size == 1
    marcwriter.write(rec_array[0])
  else
    rec_dates = []
    recs_by_date = {}
    rec_array.each do | rec |
      the_date = rec['005'].value
      rec_dates << the_date
      recs_by_date[the_date] = rec      
    end
    rec_dates.sort!
    newest = rec_dates.pop
    marcwriter.write(recs_by_date[newest])
  end
end

marcwriter.close
