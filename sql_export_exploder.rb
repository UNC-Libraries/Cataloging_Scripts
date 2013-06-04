input = ARGV[0]
outfile = ARGV[1]

lines = IO.readlines(input)
linearr = []

lines.each {|l| 
  l.chomp!
  l.gsub! /",([0-9]*),([0-9]*),"/, "\",\"\\1\",\"\\2\",\""
  l.gsub! /^"(.*)"$/, "\\1"
  larr = l.split(/","/)
  puts larr.inspect
  larr = [larr[1], larr[3], larr[4], larr[5], larr[6], larr[7]] 
  linearr << larr
}

headers = linearr.shift

line_hashes = []

linearr.each {|l|
  h = Hash[*headers.zip(l).flatten]
  subfields = l[5].gsub(/^\|/,"").split(/\|/)

  subfields.each {|sf|
   delim = sf[0]
   sf.slice!(0)
   if h.has_key?(delim) == false 
    h[delim] = sf
   else
    h[delim] << ";;;#{sf}"
   end
  }

  line_hashes << h
}

line_hashes.each {|l| headers << l.keys}
headers.flatten!.uniq!

coll = {}

headers.each {|h| coll[h] = []}

line_hashes.each {|l|
 headers.each {|hdr| coll[hdr] << "#" if l.has_key?(hdr) == false}
 l.each_pair {|k,v| coll[k] << v }
}

table = coll.values.transpose.insert(0, coll.keys)

File.open outfile, "wb" do |out|
 table.each {|l| out.puts("\"#{l.join("\"\t\"")}\"")}
end
