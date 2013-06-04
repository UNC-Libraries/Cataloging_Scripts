# Used when multiple columns are output for a single header value
# Example: Export bnum and item num. More than one item is attached.

# Instructions: 
# Export .txt file from Millennium with TAB delimiter between fields

# The field expected to be repeated in multiple columns should be the last field 
# exported.
# 
# Usage:
# ruby repeated_column_normalizer.rb [input.txt] [output.txt]

require 'rubygems'

infile = ARGV[0]
outfile = ARGV[1]
output = []

lines = IO.readlines(infile)

# From each line: Remove ", remove end of line character
lines.each do |l|
  #puts l
  l.gsub! /"/, ''
  l.chomp!
  #puts l
  #puts "\n"
end

# Grab headers into an array and count them. Number of header columns is 
# how we know where to split the line for repeating vertically 
headers = lines.shift.split(/\t/)
output << headers.join("\t")
columns = headers.count

lines.each do |l|
  line = l.split(/\t/)
  every = line.shift(columns - 1)
#  puts every.inspect 

  line.each do |l|
#    puts l.inspect
    to_out = []
    to_out << every
    to_out << l
    output << to_out.flatten.join("\t")
  end
end

output.each {|l| puts l.inspect}

File.open outfile, "wb" do |f|
  output.each {|l| f.puts l}
end
