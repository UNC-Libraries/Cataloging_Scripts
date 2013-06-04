# ruby 1.9
# runs on .csv files
# usage:
# ruby oecd_compare.rb path/to/exist_csv path/to/new_csv

require 'rubygems'
require 'facets'
require 'trie'
require 'csv'

oldfile = ARGV[0]
newfile = ARGV[1]

puts "Indexing old records..."
@new = Trie.new
newf = CSV.read(newfile)

newf.each do |r|
  u = r[5]
  @new.insert(u, r)
end

@towrite = [["bnum",
    "material type",
    "match?",
    "main entry (existing)",
    "main entry (new)",
    "title (existing)",
    "title (new)",
    "date (existing)",
    "date (new)",
    "new url"]]

CSV.foreach(oldfile) do |r|
  u = r[7]
  if @new.find(u).size > 0
    n = @new.find(u).values
    #puts n.inspect
    m = "yes"
  else
    m = "no"
  end

  bnum = r[1]
  mat = r[2]
  m = m
  mee = r[3]
  titlee = r[4]
  datee = r[5]
  
  if m == "yes"
    men = n[0][1]
    titlen = n[0][2]
    daten = n[0][3]
    nurl = n[0][4]
  else
    men = "-"
    titlen = "-"
    daten = "-" 
    nurl = "-"
  end

  @towrite << [bnum, mat, m, mee, men, titlee, titlen, datee, daten, nurl]
end


CSV.open("data/oecd_matches.csv", "w") do |c|
  @towrite.each do |r|
  c << r
  end
end