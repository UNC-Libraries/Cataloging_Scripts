require 'marc'

mrcfile = ARGV[0]
outfile = File.new(ARGV[1], "w")

MARC::Reader.new(mrcfile).each do |rec|
  the001 = rec['001'].value
  the856s = rec.find_all {|field| field.tag == '856'}
  urls = {}
  the856s.each do |field|
    field.find_all {|sf| sf.code == 'u'}.each do |url|
      urls[url.value.gsub(/http:\/\/libproxy\.lib\.unc\.edu\/login\?url=/,'')] = the001
    end
  end

  urls.each_pair do |url, id|
    outfile.puts "#{id}\t#{url}"
  end
end
