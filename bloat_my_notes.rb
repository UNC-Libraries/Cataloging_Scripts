# Makes 505 and 520 notes (the $a, anyway) long--between 8000 and 8999 characters.
# It repeats the content of the $a and IS FOR BULIDNG EVIL TEST RECORDS
# If you have several of these fields in a record, this can cause the record to
#   become too long to be a valid MARC field---Use MarcEdit to remove records with lots
#   of 505s from the file. 

# coding: utf-8
# ruby 2.3
# runs on .mrc file
# usage:
# ruby bloat_my_notes.rb path-to-mrc-file.mrc output-path.mrc

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
ids = {}

marcwriter = MARC::Writer.new(ARGV[1])

reader = MARC::Reader.new(mrcfile)
for rec in reader
  puts rec['001'].value
  hrec = rec.to_hash
#  puts JSON.pretty_generate(hrec)

  mynotes = []
  hrec['fields'].each { |f| mynotes << f if f.keys[0] =~ /5(05|20)/ }

  if mynotes.size > 0
  mynotes.each do |f|
    f.each_key do |field_tag|
      f[field_tag]['subfields'].each do |sf|
        if sf.keys[0] == 'a'
        sfa = String.new(sf['a'])
        ct = 1
#        puts sf['a'].size
        while sf['a'].size < 8999
          ct += 1
          sf['a'] << " --#{ct}-- #{sfa}"
        end

        if sf['a'].size > 8999
          sf['a'] = sf['a'][0, 8000]
        end

 #       puts sf['a'].size
        #      puts "--"
        end
      end
    end
  end
  end
  
  newrec = MARC::Record.new_from_hash(hrec)
  marcwriter.write(newrec)
end
marcwriter.close
