require 'rubygems'
require 'marc'

# TO CREATE OUTPUT FILE
# Export from Millennium: bnum(81), 856|u, 956|u
# Field delimiter: Control character 9
# Text qualifier: None
mill_url_list = ARGV[0]
newmrc = ARGV[1]
output_file = ARGV[2]

mill_urls = IO.readlines(mill_url_list)

#get rid of first line: headers
mill_urls.shift

@urlindex = {}
### urlindex structure: 
### {
###   "http://dx.doi.org/10.1007/978-3-540-74119-0"=>
###     [
###       ["233973403", 
###           ["http://dx.doi.org/10.1007/978-3-540-74119-0", "http://dx.doi.org/10.1007/978-90-481-2410-7"]
###       ]
###     ],
###   "http://dx.doi.org/10.1007/978-90-481-2410-7"=>
###     [
###       ["233973403", 
###         ["http://dx.doi.org/10.1007/978-3-540-74119-0", "http://dx.doi.org/10.1007/978-90-481-2410-7"]
###       ],
###       ["405546207", 
###         ["http://dx.doi.org/10.1007/978-90-481-2410-7"]
###       ]
###     ]
### }

mill_urls.each do |ln|
  u = ln.chomp.split("\t")
  bnum =  u.shift.sub("|a", "")
  
  _856s = u.shift.split(";")
  
  if u[0]
    _956s = u[0].split(";") 
  else
    _956s = []
  end
 
  urls = _856s + _956s
  
  urls.each do |url|
    url.sub!(/http:\/\/.*http:/, "http:")
  end

  urls.uniq!

  urls.each do |url|
    if @urlindex[url]
      @urlindex[url] << [bnum, urls]
    else
      @urlindex[url] = [[bnum, urls]]
    end
  end
end

@newrecs = []
MARC::Reader.new(newmrc).each do |rec|
  @newrecs << rec
end

@recs_to_write = []

@newrecs.each do |rec|
  #get sorted array of urls
  urls = []
  matches = []
  
  rec.each_by_tag('856') {|field| urls << field['u'] }
  urls.sort!

  urls.each do |url|
    url.sub!(/http:\/\/.*http:/, "http:")
  end
  
  urls.each do |url|
    @urlindex[url].each {|m| matches << m} if @urlindex[url]
  end
  
  matches.uniq!
  
  if matches.length == 1
    exurlset = matches[0][1]
    if urls == exurlset #exact match of URLs in records
      next
    else
      puts "partial match 1, #{matches[0][0]}"
      _999 = MARC::DataField.new('999', ' ', ' ', 
        ['a', "PARTIAL MATCH ON RECORD: #{matches[0][0]}. This record contains the following URLs: #{matches[0][1]}."])
      rec.append(_999)
      @recs_to_write << rec
    end
  elsif matches.length > 1
    exactmatches = []
    matches.each do |match|
      exactmatches << match if match[1] == urls
    end
    if exactmatches.length == 1
      next
    elsif exactmatches.length > 1
      matchids = []
      exactmatches.each {|m| matchids << m[0]}
      _999 = MARC::DataField.new('999', ' ', ' ', 
        ['a', "MULTIPLE MATCHES ON RECORDS: #{matchids}"])
      rec.append(_999)
      @recs_to_write << rec
    else
      partialmatches = []
      matches.each {|m| partialmatches << m[0]}
      _999 = MARC::DataField.new('999', ' ', ' ', 
        ['a', "PARTIAL MATCHES ON RECORDS: #{partialmatches}"])
      rec.append(_999)
      @recs_to_write << rec
    end
  else
    @recs_to_write << rec
  end
end
  
writer = MARC::Writer.new(output_file)
@recs_to_write.each {|rec| writer.write(rec)}
writer.close
