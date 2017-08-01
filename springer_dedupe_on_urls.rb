# Pull ALL Springer records into review file.
# Export: bnum, 001, 856|u, 956|u
# tab (ascii 9) field delimiter, no text qualifier, repeated field delimiter ;

require 'csv'

class Record
  attr_reader :bnum
  attr_reader :wcmrec
  attr_accessor :urls
  attr_reader :suppressed

  def initialize(row)
    @bnum = row[0]
    the001 = row[1]
    if the001 =~ /wcm/
      @wcmrec = true
    else
      @wcmrec = false
    end
    @urls = []
    row[2].split(';').each { |url| @urls << url }
    row[3].split(';').each { |url| @urls << url } if row[3]
    @suppressed = true if row[3]

    @urls.each { |url| url.gsub!("http://libproxy.lib.unc.edu/login?url=", "") }
    @urls.each { |url| url.gsub!(/https?:\/\/link\.springer\.com\//, '') }
  end

  # def inspect
  #   puts self.bnum
  # end
end

# read in file and create array for each row
input = File.open('spr_data.txt').read
rows = []
input.split(/\n/).each { |line| rows << line.split(/\t/) }
rows.shift #drop header line

# create hash of Records
rechash = {}
rows.each { |row| rechash[row[0]] =  Record.new(row) }

url_lookup = {} #hash of url values => [bnum, bnum]
wcmrecs = [] #array of wcm record bnums
url_ct = {} #hash of bnum => bnum.urls.size

rechash.values.each do |rec|
  rec.urls.each do |url|
    if url_lookup.has_key?(url)
      url_lookup[url] << rec.bnum
    else
      url_lookup[url] = [rec.bnum]
    end
  end
  wcmrecs << rec.bnum if rec.wcmrec
  url_ct[rec.bnum] = rec.urls.size
end

# new hash of just urls that occur in more than one record
dupe_urls = url_lookup.select { |k, v| v.size > 1 }

out = []
out << ['disposition', 'bnum', 'bnum(s) in set', 'url(s) in set']

dupe_urls.each do |url, bnums|
  set_bnums = []
  wcm_status = []
  rec_urls = []
  bnums.each do |bnum|
    set_bnums << bnum
    if rechash[bnum].wcmrec
      wcm_status << 'y'
    else
      wcm_status << 'n'
    end
    rec_urls << rechash[bnum].urls.sort
  end
  rec_urls.uniq!

  if rec_urls.size == 1
    if wcm_status.include?('y')
      bnums.each do |bnum|
        if rechash[bnum].wcmrec
          out << ['keep--wcm record', bnum, set_bnums, rec_urls]
        else
          out << ['delete', bnum, set_bnums, rec_urls] 
        end
      end
      if wcm_status.select{|wcm| wcm == 'y'}.size > 1
        out << ['check', 'multiple WCM records with same URL(s)', set_bnums, rec_urls]
      end
    else
      out << ['check', 'dupe URLs in records, but no WCM record in group', set_bnums, rec_urls]
    end
  else
    if wcm_status.include?('y')
      out << ['check', 'records have varying urls; WCM rec(s) in set', set_bnums, rec_urls]
    else
      out << ['check', 'records have varying urls; no WCM rec(s) in set', set_bnums, rec_urls]
    end
  end  
end

CSV.open('springer_dupe_output.csv', "wb") do |csv|
  out.each { |ln| csv << ln }
end






