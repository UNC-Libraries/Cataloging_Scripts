# ruby 1.9
# runs on .mrc file
# usage:
# ruby split_by_record_type.rb path/to/mrcfile

require 'rubygems'
require 'marc'
require 'enhanced_marc'
require 'locale/info'
require 'facets'

file = ARGV[0]
@recs = []
MARC::Reader.new(file).each {|rec| @recs << rec}

puts @recs.size

@rts = Hash.autonew

@recs.each do |r|
  rt = (r.class.to_s - "MARC::" - "Record")
  if @rts.has_key?(rt) == false
    @rts[rt] = []
    @rts[rt] << r
  else
    @rts[rt] << r
  end
end

@rts.each_pair do |k, v|
  writer = MARC::Writer.new("record_split_#{k}.mrc")
  v.each {|r| writer.write(r)}
  writer.close
end


