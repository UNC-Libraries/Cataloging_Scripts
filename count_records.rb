require 'rubygems'
require 'marc'

a = ARGV[0]

counter = 0



MARC::Reader.new(a).each {|rec| counter += 1}

puts counter  
    
  
