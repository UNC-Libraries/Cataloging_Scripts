# ruby 1.9
# runs on .mrc file
# usage:
# ruby extract_by_field_value.rb path/to/mrcfile path/to/values 001

require "trie"
require "marc"

mrcfile = ARGV[0]
valfile = ARGV[1]
tag = ARGV[2]

@recs = []
MARC::Reader.new(mrcfile).each {|rec| @recs << rec}

nums = File.open(valfile, "r").readlines

oak = Trie.new

nums.each do |num|
  oak.insert(num.chomp, 1)
#puts oak.keys
#puts "END\n\n"
end



@match = []
@nomatch = []

@recs.each do |rec|
  val = rec[tag].value
  #puts val
  lookup = oak.find(val).values
  #p lookup
  if lookup.size > 0
    @match << rec
  else
    @nomatch << rec
  end
end

  matchwriter = MARC::Writer.new('data/match.mrc')
  @match.each {|rec| matchwriter.write(rec)}
  matchwriter.close

nomatchwriter = MARC::Writer.new('data/discard.mrc')
  @nomatch.each {|rec| nomatchwriter.write(rec)}
  nomatchwriter.close
