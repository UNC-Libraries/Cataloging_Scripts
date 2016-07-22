# Output the length/size of each field in each MARC record in a file
# Only output fields longer than 2499 bytes by uncommenting the
#  if bs > 2499 phrase

require 'marc'
require 'csv'

a = ARGV[0]
results = CSV.open("output/field_lengths.csv", 'wb')
results << ['record number (order in file)','001 value', 'marc field tag', 'field byte length', 'first 25 char of field']


# Go through records in file a, writing each to outfile unless its 001 was in file b
puts "Examining records from #{a}..."
ct = 0

MARC::Reader.new(a).each do |rec|
  ct += 1
  m001s = rec.find_all {|field| field.tag == '001'}
  if m001s.size > 0
    the001 = m001s[0].value
  else
    the001 = ''
  end
  rec.fields.each do |f|
    field_string = f.to_s
    field_string.gsub!(/^... .. /, '')
    first_bit = field_string[0..25]
    bs = field_string.bytesize
    results << [ct, the001, f.tag, bs, first_bit] #if bs > 2499
  end

end #MARC::Reader.new(a).each do |rec|

