require 'csv'
require 'amatch'
require 'facets'
include Amatch

#input file - list of identifiers from internet archive. no header.
input = 'data/springer_dupe_in.csv'
#output file - columns: identifier, 001, 003, 035
output = 'output/springer_dupe_out.csv'

## read in file
dupe_lines = CSV.read(input)

# create hash to gather info on records with the same URL. 
# key is url, values are PossDupe Structs, as defined below
all_data = {}

PossDupe = Struct.new(:bnum, :_001, :_003, :_005, :title, :author, 
  :date008, :date260, :supp, :hsl)

# populate all_data
dupe_lines.each do |line|
  url = line[6]

  # 245a - downcase, chop off after :
  #title = line[7].partition(":")[0].downcase.gsub(/[-.,!?\/\\']|\[|\]|\(|\)/, " ").squish
  title = line[7].downcase.gsub(/[-.,!?\/\\':]|\[|\]|\(|\)/, " ").squish

  # 100a - chop off after ,
  author = line[8].partition(",")[0].downcase unless line[8] == nil

  # bcode - if = n, yes, else no
  if line[13] == "n"
    supp = true 
  else 
    supp = false
  end
  
  # loc - if includes noh, yes, else no
  if line[14].include?("noh")
    hsl = true
  else
    hsl = false
  end
  
  pd = PossDupe.new(line[0], line[1], line[2], line[3], title, author, 
    line[9], line[10], supp, hsl)
                  
  unless all_data.has_key?(url)
    all_data[url] = {:recs => {:srec => nil, :orec => nil}, :hsl => nil,
      :tjarowinkler => nil, :tpairdist => nil,
      :authors_present => nil, :ajarowinkler => nil, :apairdist => nil,
      :oclclater => nil, :datematch => nil,
      :oclcbnum => nil, :springerbnum => nil,
      :confidence => 0
      }
  end
  
  all_data[url][:recs][:srec] = pd if pd._003 == "Springer"
  all_data[url][:recs][:orec] = pd if pd._003 == "OCoLC"
 
end

# How many records for each url?
counterh = {}
all_data.each_value do |val|
  numrecs = val[:recs].size
  if counterh.has_key?(numrecs)
    counterh[numrecs] = counterh[numrecs] + 1
  else
    counterh[numrecs] = 1
  end
end
counterh.each_pair {|k, v| puts "#{k} records for 1 url: #{v} instances"}
puts "\n\n"


outputs = []

all_data.each_pair do |key, val|
  srec = val[:recs][:srec]
  orec = val[:recs][:orec]
  
  #calculate title similarity
  tjw = JaroWinkler.new(srec.title)
  all_data[key][:tjarowinkler] = tjw.match(orec.title)
  
  tp = PairDistance.new(srec.title)
  all_data[key][:tpairdist] = tp.match(orec.title)
  
  #calculate author similarity
  author_count = 0
  author_count += 1 if srec.author
  author_count += 1 if orec.author
  
  if author_count < 2
    all_data[key][:authors_present] = false
    all_data[key][:ajarowinkler] = 0
    all_data[key][:apairdist] = 0
  else
    all_data[key][:authors_present] = true
    ajw = JaroWinkler.new(srec.author)
    all_data[key][:ajarowinkler] = ajw.match(orec.author)
    ap = PairDistance.new(srec.author)
    all_data[key][:apairdist] = ap.match(orec.author)
  end  
   
  #is springer the earlier record? 
  if srec._005 < orec._005
    all_data[key][:oclclater] = true
  else 
    all_data[key][:oclclater] = false
  end
  
  #get difference between dates
  date008diff = orec.date008.to_i - srec.date008.to_i
  date008diffa = date008diff.abs * -1
  date260diff = orec.date260.to_i - srec.date260.to_i
  date260diffa = date260diff.abs * -1  
  all_data[key][:datematch] = (date008diffa + date260diffa) / 2
  
  all_data[key][:confidence] += all_data[key][:tjarowinkler]
  all_data[key][:confidence] += all_data[key][:tpairdist]
  
  asim = all_data[key][:ajarowinkler] + all_data[key][:apairdist]
  
  if all_data[key][:authors_present] == true
    all_data[key][:confidence] += 2 if asim > 1.75
    all_data[key][:confidence] += (2 - asim)*-1 if asim < 1.75
  end
 
  if orec.hsl == true || srec.hsl == true
    all_data[key][:hsl] = true 
  else
    all_data[key][:hsl] = false 
  end
  
  if all_data[key][:datematch] == 0
    all_data[key][:confidence] += 2
  elsif all_data[key][:datematch] == -1
    all_data[key][:confidence] += 0.5
  else 
    all_data[key][:confidence] += all_data[key][:datematch]
  end
end

CSV.open(output, "w") do |csv|
  csv << ["url", "spr title", "oclc title", "t jw sim", "t pd sim",
    "spr auth", "oclc auth", "auth in both recs?", "a jw sim", "a pd sim",
    "oclc later?", "date diff", "spr008", "spr260", "oclc008", "oclc260",
    "spr bnum", "oclc bnum", "hsl?", "confidence"
    ]
          
  all_data.each_pair do |url, recdata|
    out = []
    srec = recdata[:recs][:srec]
    orec = recdata[:recs][:orec]
  out << url
  out << srec.title
  out << orec.title
  out << recdata[:tjarowinkler]
  out << recdata[:tpairdist]
  out << srec.author
  out << orec.author
  out << recdata[:authors_present]
  out << recdata[:ajarowinkler]
  out << recdata[:apairdist]
  out << recdata[:oclclater]
  out << recdata[:datematch]  
  out << srec.date008
  out << srec.date260
  out << orec.date008
  out << orec.date260
  out << srec.bnum
  out << orec.bnum
  out << recdata[:hsl]  
  out << recdata[:confidence]  
    csv << out
  end
end
