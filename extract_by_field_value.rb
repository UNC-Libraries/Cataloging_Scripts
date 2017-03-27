# ruby 1.9
# runs on .mrc file
# usage:
# ruby extract_by_field_value.rb

require "trie"
require "marc"
require 'highline/import'

mrcfile = ARGV[0]
valfile = ARGV[1]
tag = ask("Enter the 3-digit MARC field tag you want to match on (example: 001)")
subfield = ask("If you want to match on a specific subfield in that MARC tag, enter the subfield delimter (example: z). If you want to match on the whole field, just hit Enter.")

if subfield == ""
    subfield = nil
end

write_matches = ask("Do you want to create a file of MARC records that match the values in your list? Type y or n and hit Enter.")
write_non_matches = ask("Do you want to create a file of MARC records that DO NOT match the values in your list? Type y or n and hit Enter.")

puts "Reading in MARC records...\n"
@rec_info = Hash.new

if subfield
  matchpoint = "#{tag}$#{subfield}"
else
  matchpoint = "#{tag}"
end

MARC::Reader.new(mrcfile).each do |rec|
  rec_id = rec['001'].value
  if subfield
    match_data = rec[tag][subfield].value
  else
    match_data = rec[tag].value
  end

  if @rec_info.has_key?(match_data)
    @rec_info[match_data] << rec_id
  else
    @rec_info[match_data] = [rec_id]
  end
end

puts "Reading in values to match on...\n"
nums = File.open(valfile, "r").readlines

oak = Trie.new

nums.each do |num|
  oak.insert(num.chomp, 1)
end

puts "Checking for matches on #{matchpoint}...\n"

@match_ids = []
@nomatch_ids = []

puts @rec_info.size

@rec_info.each_key do |k|
  lookup = oak.find(k).values
  if lookup.size > 0
    @match_ids << @rec_info[k]
  else
    @nomatch_ids << @rec_info[k]
  end
end


puts "Writing out MARC records...\n"
@match_ids.flatten!.uniq!
@nomatch_ids.flatten!.uniq!
matchwriter = MARC::Writer.new("data/match_on_#{tag}#{subfield}.mrc")
nomatchwriter = MARC::Writer.new("data/no_match_on_#{tag}#{subfield}.mrc")

MARC::Reader.new(mrcfile).each do |rec|
  thisid = rec['001'].value
  if write_matches == 'y'
    matchwriter.write(rec) if @match_ids.include?(thisid)
  end
  if write_non_matches == 'y'
    nomatchwriter.write(rec) if @nomatch_ids.include?(thisid)
  end
end

matchwriter.close
nomatchwriter.close


puts "Done!"
