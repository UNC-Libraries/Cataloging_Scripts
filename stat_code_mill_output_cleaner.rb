require 'rubygems'
require 'facets'
require 'fastercsv'
require 'open-uri'

Row = Struct.new(:bnum, :url, :title, :mattype, :blvl, :order, :callno, :nums, :mess)

rows = [] # holds initial Rows constructed from text file

file = 'data/INTERNET-ONLINE_DB_unsuppressed.txt'
file_lines = IO.readlines(file)

# split lines at tabs
# create Row struct from each line and send that row to "unprocessed"
file_lines.each do |ln|
  a = ln.chomp.split("\t")
  r = Row.new
  r[:bnum] = a.shift
  r[:url] = a.shift
  r[:title] = a.shift
  r[:mattype] = a.shift
  r[:blvl] = a.shift
  r[:order] = []
  r[:callno] = []
  r[:nums] = 0
  r[:mess] = a
  rows << r
end

rows.shift # pop headers off stack

#
rows.each do |r|
  r.mess.each do |x|
    if x == nil
      next
    elsif x =~ /^o[0-9x]* *$/
        r.order << x
    elsif x =~ /^(INTERNET|ONLINE)/
      r.callno << x
      r.nums += 1
    else
      r.nums += 1
    end
  end
end


FasterCSV.open('data/stats_code_report.csv', "wb") do |csv|
  csv << ['bnum', 'url', 'title', 'mat type', 'blvl', 'orders', "call nos", "num of cns"]
  rows.each do |r|
    csv << [r.bnum, r.url, r.title, r.mattype, r.blvl, r.order.ergo.join(","), r.callno.join(','), r.nums]
  end #working.each do |r|
end #still_have_access = FasterCSV.open('../datasources/still_have_access.csv', "w") do |csv|