require 'rubygems'
require 'marc'
require 'set'
load '../sersol/lib/marc_extended/record.rb'

a = ARGV[0]
b = ARGV[1]

ra = []
rb = []


MARC::Reader.new(a).each do |rec|
  ssid = rec.ssid
  ra << ssid
  end #MARC::Reader.new(a).each do

MARC::Reader.new(b).each do |rec|
  rec.localize001
  ssid = rec.ssid
  rb << ssid
  end #MARC::Reader.new(b).each do |rec|



  rintersect = ra & rb
  wrecs = []
  MARC::Reader.new(a).each do |rec| 
    ssid = rec.ssid
    wrecs << rec if rintersect.include?(ssid)
  end #MARC::Reader.new(a).each do |rec|
  
    puts "FOUND: #{wrecs.size}"
         
  writer = MARC::Writer.new("data/intersect_of_ a_and_b.mrc")
  wrecs.each {|rec| writer.write(rec)}
  
    
  
