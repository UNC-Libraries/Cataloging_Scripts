require 'rubygems'
require 'marc'
require 'enhanced_marc'
require 'locale/info'
require 'facets'

@recs = []
MARC::Reader.new('data/transformed.mrc').each {|rec| @recs << rec}

puts @recs.size

@rts = {}

def do_lang(r, rt, l)
  ls = @rts[rt][:langs]
  if ls.has_key?(l) == false
    ls[l] = 1
  else
    ls[l] += 1
  end
end

@recs.each do |r|
  rt = (r.class.to_s - "MARC::" - "Record")
  l = ""
  lc = r.languages[0]
  if lc
    l = lc.name
  else
    l = "no lang code"
  end
  #l = 'no lang code' if l == ""
  if @rts.has_key?(rt) == false
  @rts[rt] = {}
  @rts[rt][:count] = 1
  @rts[rt][:langs] = {}
else
  @rts[rt][:count] += 1
end

  do_lang(r, rt, l)
  end

@rts.each_key do |k|
  puts k + ": " + @rts[k][:count].to_s
  lang_rept = []
  @rts[k][:langs].each_pair {|l, c| lang_rept << [c, l]}
  
  
 # lang_rept.sort {|a, z| z[0] <=> a[0]}
  #lang_rept.reverse  
  lang_rept.each {|e| puts "#{e[0].to_s}\t#{e[1]}"}
end


