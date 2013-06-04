require 'csv'
require 'marc'
require 'nokogiri'
require 'open-uri'

#input file - list of identifiers from internet archive. no header.
input = 'data/ai_ids.csv'
#output file - columns: identifier, 001, 003, 035
output = 'output/ai_ids_with_numbers.csv'

# get identifiers
all_ids = CSV.read(input)
fullcount = all_ids.count.to_s
gocount = 0

base = 'http://www.archive.org/download/'
marcend = '_marc.xml'

@id_w_data = []

# holds values from each record to be kept while processing
@arr = []

def fieldgather(tag)
  if @tags.include?(tag)
    if @tags.count(tag) > 1
      fields = []
      @rec.each_by_tag(tag) {|field| fields << field.value}
      @arr.push fields
    else
      @arr.push @rec[tag].value
    end
  else
    @arr.push('na')
  end
end

def fetch(uri)
  begin
    @marcxml = uri.open

  rescue OpenURI::HTTPError
    @arr.push("ERROR - MARC FILE NOT FOUND")
    @status = 'broken'

  rescue StandardError
    @arr.push("ERROR - OTHER CONNECTION ERROR")
    @status = 'broken'
  end

end

def into_marc(marcxml)
  begin
    @rec = MARC::XMLReader.new(marcxml).first

  rescue StandardError
    @arr.push('ERROR - BAD METADATA OR MARC PROBLEM')
    @status = 'malformed'
  end

end

CSV.open(output, "a") do |csv|
  csv << ['identifier', '001', '003', '035']

  all_ids.flatten.each do |id|
    @arr = [id]
    theurl = URI.parse(base + id + '/' + id + marcend)
    fetch(theurl)
  
    unless @status == 'broken'
      into_marc(@marcxml)

      unless @status == 'malformed'
        @tags = @rec.tags
        fieldgather('001')
        fieldgather('003')
        fieldgather('035')
      end
    end
    
    #puts @arr.inspect
    csv << @arr

    gocount += 1
    puts gocount.to_s + " of " + fullcount + " - id: " + id



    @rec = ''
    @tags = []
    @arr = []
    @status = ''
  end


 
end