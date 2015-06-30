# ruby 2.0
# runs on .mrc file
# check .mrc file for the following records before using to avoid complications:
# - with more than 1 773
# - missing 773

# usage:
#   ruby split_mrc_based_on_773.rb

# Creates one new .mrc file per unique 773 value in input file.

require 'marc'

mrcfile = 'data/recs.mrc'

gatherer = {}

MARC::Reader.new(mrcfile).each do |rec|
  the773s = []
  rec.fields('773').each { |f| the773s << f['t'] if f['t'] }
  the773s.each do |t|
    t.gsub!(/\. */,'_')
    if gatherer[t.to_sym]
      gatherer[t.to_sym] << rec
    else
      gatherer[t.to_sym] = [rec]
    end
  end
end

gatherer.each_pair do |t, recs|
  writer = MARC::Writer.new("output/#{t.to_s}.mrc")
  ct = 0
  recs.each { |r| writer.write(r); ct += 1}
  writer.close
  puts "#{ct} records written to #{t.to_s}.mrc\n"
end
  
