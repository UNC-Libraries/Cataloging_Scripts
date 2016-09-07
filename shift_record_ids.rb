# Shift record id from one record to the next.
# The id of the last record will become the id of the first
# Thrown together for evil testing in attempt to reproduce an III bug

# coding: utf-8
# ruby 2.3
# runs on .mrc file
# usage:
# ruby shift_record_ids.rb path-to-mrc-file.mrc output-path.mrc

require "marc"
require "json"
require 'pp'

#  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#    SCRIPT INPUT
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Incoming MARC records
mrcfile = ARGV[0]

unless File.exist?(mrcfile)
  puts "\n\nERROR: #{mrcfile} is missing. Please check file names and run script again.\n\n"
  exit
end


def get_fields(hrec, tag)
  return hrec['fields'].find_all { |f| f.has_key?(tag) }
end

def get_sf_values_detail(hrec, tag, sfdelim)
  subfields = []
  fields = get_fields(hrec, tag)
  fields.each do |f|
    mysfs = []
    f[tag]['subfields'].each do |sf|
      mysfs << sf[sfdelim] if sf.has_key?(sfdelim)
    end
    subfields << mysfs
  end
  return subfields
end

def get_sf_values_summary(hrec, tag, sfdelim)
  subfields = []
  fields = get_fields(hrec, tag)
  fields.each do |f|
    f[tag]['subfields'].each do |sf|
      subfields << sf[sfdelim] if sf.has_key?(sfdelim)
    end
  end
  return subfields
end
ids = []


marcwriter = MARC::Writer.new(ARGV[1])
reader = MARC::Reader.new(mrcfile)
for rec in reader
  #  puts rec['001'].value
  ids << rec['001'].value
end

#puts ids.inspect
firstid = ids.shift
ids << firstid

#puts ""
#puts ids.inspect


reader = MARC::Reader.new(mrcfile)
for rec in reader
  rec['001'].value = ids.shift
  marcwriter.write(rec)
end
marcwriter.close
