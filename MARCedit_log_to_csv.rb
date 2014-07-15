require 'strscan'
require 'csv'

exit if Object.const_defined?(:Ocra)

log = File.open('data/error_log.txt', "r").read
lines = log.split(/\n/)

@errs = [["Field", "Part", "Error msg", "Rec ID", "245 data", "MRK File Record No"]]

lines.delete ""
lines.delete "Errors:"

recno = ''
the001 = ''
the245 = ''

lines.each do |line|
  if line =~ /^Record #:/
    recno = line.gsub! /^Record #:\s*/,''
  end

  if line =~ /^001 \(if defined\):/
    the001 = line.gsub! /^001 \(if defined\):\s*/,''
  end

  if line =~ /^245 \(if defined\):/
    the245 = line.gsub! /^245 \(if defined\):\s*/,''
  end

  if line =~ /^\t/
    line = line.gsub! /^\t/,''
    if line =~ /^\d{3}-.*?:\s*.*/
      s = StringScanner.new(line)
      s.scan /^(\d{3})(-)(.*?)(:\s*)(.*)/
      @errs << [s[1], s[3], s[5], the001, the245, recno]
    elsif line =~ /^\d{3}:\s*.*/
      s = StringScanner.new(line)
      s.scan /^(\d{3})(:\s*)(.*)/
      @errs << [s[1], '', s[3], the001, the245, recno]
    end
  end
end


@errs.each do |err|
  puts err.inspect
  puts "\n\n"
  end

if @errs.count > 0
  CSV.open("output/validation_errors.csv", 'wb') do |csv|
    @errs.each {|r| csv << r}
  end
else
  puts "All valid."
end

exit
