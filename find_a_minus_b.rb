#require 'rubygems'
require 'marc'
require 'marc_extended'
require 'marc_sersol'

a = ARGV[0]
b = ARGV[1]

print "Reading in file a..."
arecs = []
MARC::Reader.new(a).each {|rec| rec.localize001 ; arecs << rec }
print "#{arecs.size} records."

print "\n\nReading in file b..."
brecs = []
MARC::Reader.new(b).each {|rec| rec.localize001 ; brecs << rec }
print "#{brecs.size} records."

bids = []
brecs.each {|rec| bids << rec._001}
puts "\n\n"
#p bids



diff = arecs.select do |rec|
ssid = rec._001
#p ssid
bids.include?(ssid) == false

end

  
puts "\n\nFOUND: #{diff.size}"
         
  writer = MARC::Writer.new('data/diff.mrc')
  diff.each {|rec| writer.write(rec)}
  writer.close
  
    
  
