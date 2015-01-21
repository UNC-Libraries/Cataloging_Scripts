# ruby 1.9
# runs on .mrc file
# usage:
# ruby extract_by_field_value.rb path/to/mrcfile path/to/values 001

require "trie"
require "marc"
require 'highline/import'

mrcfile = "data/file_to_split.mrc"
valfile = "data/value_list.txt"
tag = ask("Enter the 3-digit MARC field tag you want to match on (example: 001)")
subfield = ask("If you want to match on a specific subfield in that MARC tag, enter the subfield delimter (example: z). If you want to match on the whole field, just hit Enter.")

puts "Reading in MARC records...\n"
@recs = []
MARC::Reader.new(mrcfile).each {|rec| @recs << rec}

puts "Reading in values to match on...\n"
nums = File.open(valfile, "r").readlines

oak = Trie.new

nums.each do |num|
  oak.insert(num.chomp, 1)
end

if subfield
  matchpoint = "#{tag}$#{subfield}"
else
  matchpoint = "#{tag}"
end

puts "Checking for matches on #{matchpoint}...\n"

@match = []
@nomatch = []

@recs.each do |rec|
  if subfield == ""
    subfield = nil
  end
  val = rec[tag].value unless subfield
  val = rec[tag][subfield] if subfield
  #puts val
  lookup = oak.find(val).values
  #p lookup
  if lookup.size > 0
    @match << rec
  else
    @nomatch << rec
  end
end

puts "Writing out matching MARC records...\n"
  matchwriter = MARC::Writer.new("data/match_on_#{tag}#{subfield}.mrc")
  @match.each {|rec| matchwriter.write(rec)}
  matchwriter.close

puts "Writing out non-matching MARC records...\n"
nomatchwriter = MARC::Writer.new("data/no_match_on_#{tag}#{subfield}.mrc")
  @nomatch.each {|rec| nomatchwriter.write(rec)}
  nomatchwriter.close

puts "Done!"
