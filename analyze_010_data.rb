require 'setup'

rec = FromFileRecordSet.new(ARGV[0])



nonum = 0
oldnums = []
newnums = []
oddnums = []

lccn_kind = lambda {|sf|
  numbers = sf.value.match(/(\D*)(\d*)(\D*)/)[2]
  if numbers.size == 8
    oldnums.push(numbers)
  elsif numbers.size == 10
    newnums.push(numbers)
  else
    oddnums.push(numbers)
  end 
}


rec.each do |r|  
  fields = r.getField('010')
  if fields
    fields.each do |f|
      f.each {|sf| lccn_kind.call(sf)}
    end #fields.each do |f|
  else nonum += 1
  end #if fields
end #rec.each do |r|

puts "pre-2000: #{oldnums.count}"
puts "2000-:    #{newnums.count}"
puts "odd:      #{oddnums.count}"
puts "no lccn:  #{nonum}"