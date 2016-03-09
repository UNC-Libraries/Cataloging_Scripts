require 'marc'

a = ARGV[0]
b = ARGV[1]
outfile = ARGV[2]

# Get 001 values from file b
b001s = []
puts "Getting 001 values from #{b}..."
MARC::Reader.new(b).each do |rec|
  m001s = rec.find_all {|field| field.tag == '001'}
  if m001s.size > 1
    puts "#{b} contains record with more than 1 001, including #{m001s[0].value}. Results do not include this record!"
  elsif m001s.size == 0
    puts "#{b} contains record with NO 001 field. Results do not include this record!"
  else
    b001s << m001s[0].value
  end
end #MARC::Reader.new(b).each do |rec|
puts "#{b001s.size} 001s in #{b}"

writer = MARC::Writer.new(outfile)

# Go through records in file a, writing each to outfile unless its 001 was in file b
puts "Examining records from #{a}..."
keeper_ct = 0
MARC::Reader.new(a).each do |rec|
  m001s = rec.find_all {|field| field.tag == '001'}
  if m001s.size > 1
    puts "#{a} contains record with more than 1 001, including #{m001s[0].value}. Results do not include this record!"
  elsif m001s.size == 0
    puts "#{a} contains record with NO 001 field. Results do not include this record!"
  else
    unless b001s.include?(m001s[0].value)
      writer.write(rec)
      keeper_ct += 1
    end
  end
end #MARC::Reader.new(a).each do |rec|
print "#{keeper_ct} records in #{a} and not in #{b}."


writer.close
  
    
  
