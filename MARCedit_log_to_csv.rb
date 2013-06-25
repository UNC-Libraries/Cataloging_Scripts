require 'strscan'
require 'csv'

log = File.open('data/log.txt', "r").read
recs = log.split(/^Record/)

p log

#puts log.class
#puts recs.inspect

lines = log.split(/\n/)

lines.each do |line|
  line.gsub! /^\s*/, ''
end
lines.delete ""
#puts lines

@errors = []
@errstate = 0
@rec = []
@errs = [["Field", "Part", "Error msg", "Rec ID", "Title"]]

lines.each do |line|
  if line =~ /^Record #:/
    @errstate = 0
    if @errs.count > 0
      @errs.each do |e|
        err = [e, @rec].flatten!
        @errors << err
      end
      @rec = []
      @errs = []
    end
  elsif line =~ /^Errors:\s*$/
    @errstate = 1
  elsif line =~ /^001 \(if/ && @errstate == 0
    s = StringScanner.new(line)
    s.skip_until /:\s*/
    @rec << s.post_match
  elsif line =~ /^245 \(if/  && @errstate == 0
    s = StringScanner.new(line)
    s.skip_until /:\s*/
    @rec << s.post_match
  elsif @errstate == 1
    if line =~ /^\d{3}-.*?:\s*.*/
      s = StringScanner.new(line)
      s.scan /^(\d{3})(-)(.*?)(:\s*)(.*)/
      @errs << [s[1], s[3], s[5]]
    elsif line =~ /^\d{3}:\s*.*/
      s = StringScanner.new(line)
      s.scan /^(\d{3})(:\s*)(.*)/
      @errs << [s[1], '', s[3]]
    end
  end

  puts "#{@errstate}\t#{line}"
end

@errors_to_ignore = [["041", "ind1", "Invalid data (\\)  Indicator can only be 01."]]

@output = []
@errors.each do |e|
  #puts "\n\nERR: #{e}"
  @ignore = false
  @perr = [e[0], e[1], e[2]]
  #puts "PERR: #{@perr}"

  @errors_to_ignore.each do |i|
    #puts "IGNORE: #{i}"
    if @perr == i
      @ignore = true
      break
    else
      @ignore == false
    end
  end
  #p @ignore
  puts "\n\nRESULTS:"
  if @ignore == false
    p e
    @output << e
  end
end

if @output.count > 0
  CSV.open("output/validation_log.csv", 'wb') do |csv|
    @output.each do |r|
      csv << r
    end
  end
else
  puts "All valid."
end
