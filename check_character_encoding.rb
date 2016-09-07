# Usage:
# ruby check_character_encoding.rb path_to/mrc_file.mrc

# Creates two new .mrc files in the same location as the input file. One will have _UTF8.mrc on the end and the other will have _MARC8.mrc
# Writes each record from the input file to the appropriate new file based on the value of LDR/09

require 'rubygems'
require 'marc'

mrcpath = ARGV[0]
reader = MARC::Reader.new(mrcpath)

utf8path = mrcpath.gsub(/\.mrc/, '_UTF8.mrc')
utf8writer = MARC::Writer.new(utf8path)
utf8ct = 0

marc8path = mrcpath.gsub(/\.mrc/, '_MARC8.mrc')
marc8writer = MARC::Writer.new(marc8path)
marc8ct = 0

invalidct = 0

reader.each do |rec|
  if rec.leader[9] == 'a'
    utf8writer.write(rec)
    utf8ct += 1
  elsif rec.leader[9] == ' '
    marc8writer.write(rec)
    marc8ct += 1
  else
    invalidct += 1
  end
end

puts "#{utf8ct} UTF8 records written to #{utf8path}."
puts "#{marc8ct} MARC8 records written to #{marc8path}."
puts "Some records had invalid code in LDR/09" if invalidct > 0
