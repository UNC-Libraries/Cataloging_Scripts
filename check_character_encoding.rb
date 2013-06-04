require 'rubygems'
require 'marc'
require 'enhanced_marc'
exit if Object.const_defined?(:Ocra)

puts "Enter name of .mrc file."
puts "(If you type the first couple of letters and hit TAB, the name will probably autocomplete.)"

mrcfile = gets.chomp

mrcpath = "data/#{mrcfile}"

reader = MARC::Reader.new(mrcpath)

ldrs = []

reader.each {|r| ldrs << r.leader}

enc = []

ldrs.each {|l| enc << l[9]}

if enc.include?(97)
  File.new('data/utf8.txt', 'w')
else
  File.new('data/mrc8.txt', 'w')
  end