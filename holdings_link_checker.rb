require 'rubygems'
require 'celerity'
require 'fastercsv'

file = ARGV[0]

csv = FasterCSV.read(file, :headers => true)
to_check = []
results = []

counter = 0

csv.each do |r|
  hnum = r['hnum']
  title = r['title']
  url = r['url']
  to_check << [hnum, title, url]
end


b = Celerity::Browser.new

to_check.each do |r|
  b.goto(r[2])
  page = b.html
  if page.match(/Search TRLN/) != nil
    access = "link ok"
  else
    access = "link not ok"
  end
  results = [r[0], r[1], r[2], access]
  counter += 1
  puts "#{counter} of #{csv.size}, access = #{access}"
  
  sleeptime = rand(1)

  sleep sleeptime

  FasterCSV.open("output/holdings_link_results.csv", "a") do |c|
    c << results
  end
end

