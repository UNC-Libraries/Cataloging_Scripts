require 'rubygems'
require 'marc'
load '../sersol/lib/marc_extended/record.rb'

a = ARGV[0]
b = ARGV[1]

ra = []
rb = []


MARC::Reader.new(a).each do |rec|
  rec.localize001
  ssid = rec.ssid
  ra << ssid
end #MARC::Reader.new(a).each do

MARC::Reader.new(b).each do |rec|
  rec.localize001
  ssid = rec.ssid
  rb << ssid
end #MARC::Reader.new(b).each do |rec|


only_in_a = ra - rb
only_in_b = rb - ra

warecs = []
MARC::Reader.new(a).each do |rec| 
  rec.localize001
  ssid = rec.ssid
  warecs << rec if only_in_a.include?(ssid)
end #MARC::Reader.new(a).each do |rec|

puts "ONLY IN #{a}: #{warecs.size}"

writer = MARC::Writer.new('data/unique_to_a.mrc')
warecs.each {|rec| writer.write(rec)}

wbrecs = []
MARC::Reader.new(b).each do |rec| 
  rec.localize001
  ssid = rec.ssid
  wbrecs << rec if only_in_b.include?(ssid)
end #MARC::Reader.new(a).each do |rec|

puts "ONLY IN #{b}: #{wbrecs.size}"

writer = MARC::Writer.new('data/unique_to_b.mrc')
wbrecs.each {|rec| writer.write(rec)}
