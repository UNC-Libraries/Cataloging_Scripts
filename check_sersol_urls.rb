# Checks SerSol urls for access
# TO USE:
# Export list from Millennium with the following parameters: 
## b 81
## b ! 001
## b ! 856|u
## b ! 856|x
## b ! 245|a
## o 81

## Field delimiter: Control character 9
## File location/name: 
### r:/doc/personalOutput/code/sersolsol/data/sersol_deletes.txt

# Run: 
## jruby -S bin/check_sersol_urls.rb


require 'rubygems'
require 'celerity'
require 'csv'

Row = Struct.new(:bnum, :ssnum, :access, :url, :db, :title, :order, :loc, :ostat, :locstat)

OTHERLIBS = ["k", "kdav", "kdcd", "kdfc", "kdoc", "kdvd", "kfa5", "kfac", "kfapd", "knav", "kncd", "knfc", "knfci", "knfm", "knfmi", "knlv", "knsc", "knvd", "krca", "krcp", "kref", "krefd", "krefi", "krefn", "kreft", "kres", "kres2", "krlei", "krlsc", "krnbs", "kspba", "kspca", "kspci", "kspcp", "kspen", "ksppo", "ksta", "ksta4", "ksta5", "kstaa", "kstaf", "kstar", "kstas", "kwec", "kwer", "kwer2", "kweu", "kwrar", "kwrbr", "kwrc", "kwrc2", "kwrc3", "kwrma", "kz", "kzaad", "kzacq", "kzad", "kzadd", "kzcat", "kzcir", "kzfi", "kzit", "kzps", "kzref", "kzser", "kzts", "noa", "nocl", "nods", "noh", "noh9", "noh@", "noha", "nohas", "nohb", "nohba", "nohbb", "nohbc", "nohbd", "nohbf", "nohbg", "nohbh", "nohbm", "nohbo", "nohbr", "nohbs", "nohbt", "nohbv", "nohe", "noheb", "nohf", "nohg", "nohh", "nohi", "nohk1", "nohk2", "nohk3", "nohk4", "nohk5", "nohk6", "nohm", "nohmf", "nohn", "noho", "nohr", "nohs", "nohss", "noht", "nohu", "nohv", "nohw", "nohx", "nohy", "nohz", "nohzh", "nohzx", "nomk", "noxx", "nozh", "nozz"]

rows = [] # holds initial Rows constructed from text file

file = 'data/sersol_deletes.txt'
file_lines = IO.readlines(file)

# split lines at tabs
# create Row struct from each line and send that row to "unprocessed"
file_lines.each do |ln|
  a = ln.chomp.split("\t")
  r = Row.new
  r[:bnum] = a[0]
  r[:ssnum] = a[1]
  r[:url] = a[2]
  r[:db] = a[3]
  r[:title] = a[4]
  r[:order] = a[5]
  if a[6]
    loc_str = a[6].strip
    loc_squ = loc_str.gsub(/\s+/, ' ')
    r[:loc] = loc_squ
  else
    r[:loc] = ""
  end
  rows << r
end

rows.shift # pop headers off stack

#check urls and set access property
b = Celerity::Browser.new
puts "Checking access..."

@done_ct = 1
@step = 10
rows.each do |r|
  b.goto(r.url)
  if b.html.include? "SS_NoJournalFoundMsg"
    r[:access] = "no"
    message = "#{r.bnum} = no access"
  elsif b.html.include? "SS_Holding"
    r[:access] = "yes"
    message = "#{r.bnum} = WORKING LINK"
  else
    r[:access] = "check manually"
    message = "#{r.bnum} = needs manual check"
  end
  puts "#{message}\t\t\t#{@done_ct} of #{rows.size} (#{@done_ct.to_f/rows.size * 100}% complete)"
  sleep 1
  @done_ct += 1

end

# check and set order records
rows.each do |r|
  r.ostat = r.order if r.order =~ /o.*/
end

# check and set locations
rows.each do |r|
  if r.loc == nil
    r.locstat = "no location"
  else
    rlocs = r.loc.split(",")
    test = rlocs - OTHERLIBS
    if test.size == rlocs.size
      next
    else
      r.locstat = rlocs.select {|c| OTHERLIBS.include?(c)}
    end
    puts r.bnum + "\t" + r.locstat.join(",")
  end
end


CSV.open('data/delete_report.csv', "wb") do |csv|
  csv << ['Record #', 'SS#', 'URL', 'Access?', 'Database', 'Title', 'Notes', "Note", "Order record?", "Other libraries?"]
  rows.each do |r|
    csv << [r.bnum, r.ssnum, r.url, r.access, r.db, r.title, "", "", r.ostat, r.locstat]
  end #working.each do |r|
end #still_have_access = CSV.open('../datasources/still_have_access.csv', "w") do |csv|

puts "\n\nJOB COMPLETE\nType any key and hit enter to exit."
key = gets
exit if key =~ /.*/
