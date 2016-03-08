require 'rubygems'
require 'marc'

mrcfile = 'new_springer_marc.mrc'
file = 'existing_springer.txt'
file_lines = IO.readlines(file)
file_lines.shift

#puts file_lines.inspect

@exrecs = []

file_lines.each do |ln|
  a = ln.chomp.split("\t")
  exrec = []
  
  #001 is 0 element of @exrecs
  exrec << a.shift.sub("|a", "")

  #create a sorted array of urls from any 856s and 956s that exist
  #remove proxy prefixes
  #send this sorted array to be 1 element of @exrecs 
  _856s = a.shift.split(";")
  _956s = a[0]
  if _956s
    _956s = _956s.split(";") 
  else
    _956s = []
  end
 
  urls = _856s + _956s
  
  urls.each do |url|
    url.sub!("http://libproxy.lib.unc.edu/login?url=", "")
  end
  
  exrec << urls.sort 
  @exrecs << exrec
end

urlindex = {}

@exrecs.each do |rec|
  rec[1].each do |url|
    if urlindex[url]
      urlindex[url] << rec
    else
      urlindex[url] = [rec]
    end
  end
end

### urlindex structure: 
### {
###   "http://link.springer.com/10.1007/978-3-540-74119-0"=>
###     [
###       ["233973403", 
###           ["http://link.springer.com/10.1007/978-3-540-74119-0", "http://link.springer.com/10.1007/978-90-481-2410-7"]
###       ]
###     ],
###   "http://link.springer.com/10.1007/978-90-481-2410-7"=>
###     [
###       ["233973403", 
###         ["http://link.springer.com/10.1007/978-3-540-74119-0", "http://link.springer.com/10.1007/978-90-481-2410-7"]
###       ],
###       ["405546207", 
###         ["http://link.springer.com/10.1007/978-90-481-2410-7"]
###       ]
###     ]
### }

@newrecs = []
MARC::Reader.new(mrcfile).each {|rec| @newrecs << rec}

@newrecs.each do |rec|
  #get sorted array of urls
  
  urls = []
  matches = []
  
  rec.each_by_tag('856') {|field| urls << field['u'] }
  urls.sort!

  urls.each do |url|
    urlindex[url].each {|m| matches << m} if urlindex[url]
  end
  
  matches.uniq!
  
  if matches.length == 1
    exurlset = matches[0][1]
    if urls == exurlset
      puts "exact match 1, #{matches[0][0]}"
      #move 001 to 598
      _598 = MARC::DataField.new('598', ' ', ' ', ['a', rec['001'].value])
      rec.append(_598)
      #insert 001 from exrec
      rec['001'].value = matches[0][0]
      #      _001 = MARC::ControlField.new('001', matches[0][0])
      #     rec << _001
    else
      puts "partial match 1, #{matches[0][0]}"
      #insert partial match 598
      _598 = MARC::DataField.new('598', ' ', ' ', 
        ['a', "PARTIAL MATCH ON RECORDS (001): #{matches[0][0]}"])
      rec.append(_598)
    end
  elsif matches.length > 1
    exactmatches = []
    matches.each do |match|
      exactmatches << match if match[1] == urls
    end
    if exactmatches.length == 1
      #move 001 to 598
      _598 = MARC::DataField.new('598', ' ', ' ', ['a', rec['001'].value])
      rec.append(_598)
      #insert 001 from exrec
      rec['001'].value = exactmatches[0][0]
      puts "exact match +1, #{exactmatches[0][0]}"
    elsif exactmatches.length > 1
      #insert multiple match 598
      match001s = []
      exactmatches.each {|m| match001s << m[0]}
      _598 = MARC::DataField.new('598', ' ', ' ', 
        ['a', "MULTIPLE MATCHES ON RECORDS (001): #{match001s}"])
      rec.append(_598)
      puts "MULTIPLE MATCHES: 001s of existing matches: #{match001s}"
    else
      #insert partial matches 598
      partialmatches = []
      matches.each {|m| partialmatches << m[0]}
      _598 = MARC::DataField.new('598', ' ', ' ', 
        ['a', "PARTIAL MATCHES ON RECORDS (001): #{partialmatches}"])
      rec.append(_598)
      puts "PARTIAL MATCHES: 001s of partial matches: #{partialmatches}"
    end
  else
    #insert no match 598
    _598 = MARC::DataField.new('598', ' ', ' ', 
      ['a', "NO MATCH"])
    rec.append(_598)
    puts "NO MATCH, record #{rec['001'].value}"
  end
  
  #each url:
  ## get array of matches from urlindex
  ## if there is a match:
  ### each match -- does urlarray match completely?
  #### if yes, set counter
  #### if counter == 1
  ##### move 001 to 598
  ##### set new 001 using 001 from match
  #### if counter > 1
  ##### set 598 to "WARNING: Matches more than one existing record"
  #### if counter == 0
  ##### set 598 to "WARNING: Partial match with {list of 001s from urlindex match}
  ## if there was no match:
  ### do nothing
end

writer = MARC::Writer.new('output/springer_matched.mrc')
@newrecs.each {|rec| writer.write(rec)}
writer.close
