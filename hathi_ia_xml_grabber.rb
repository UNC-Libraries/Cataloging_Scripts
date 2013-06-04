# Written for Ruby 1.9
# Author: Kristina Spurgin
# Last update: 20121121

# Downloads individual {iaidentifier}_meta.xml file for each IA id in a CSV file.
# CSV file name/location: data/ai_ids.csv
# You must create a directory named xml_meta in your script's home directory.
# The individual XML files will be saved to this directory. 
# Creates an error report in: output/ai_xml_gather_errors.csv

# Revision history
# 20121121 Don't download MARC-XML from IA. We only need the meta XML files. 
#          Added more documentation to script.

require 'csv'
require 'open-uri'

## Dirty hack for dealing with results too long to be returned as a string
## Found here: 
## http://stackoverflow.com/questions/1376268/tempfile-and-garbage-collection
OpenURI::Buffer::StringMax = 10000000000000

#input file - list of identifiers from internet archive. no header.
input = 'data/ai_ids.csv'

#error log file and array to which errors will be pushed
log = 'output/ai_xml_gather_errors.csv'
@arr = []

@base = 'http://www.archive.org/download/'
#marcend = '_marc.xml'
metaend = '_meta.xml'


def fetch(id, xmltype)
  
  @status = nil
  @thefile = nil
    
  ending = "_#{xmltype}.xml"
  theuri = URI.parse(@base + id + '/' + id + ending)
    
  begin
    @thefile = theuri.open      

  rescue OpenURI::HTTPError
    @error_array.push [id, xmltype, theuri, "ERROR - FILE NOT FOUND"]
    @status = 'broken'

  rescue StandardError
    @error_array.push [id, xmltype, theuri, "ERROR - OTHER CONNECTION ERROR"]
    @status = 'broken'
  end

  begin
    unless @status == 'broken'
      content = @thefile.string
      if @thefile.readline.include?("html")
        @error_array.push [id, xmltype, theuri, "ERROR - HTML FILE RETURNED"]
      else
        fileloc = "xml_#{xmltype}/#{id}.xml"
        thefile = File.new(fileloc, "w")
        thefile.write(content)
        thefile.close
      end
    end
  end
end

# get identifiers
all_ids = CSV.read(input)
fullcount = all_ids.count.to_s
gocount = 0

CSV.open(log, "a") do |csv|
  csv << ['identifier', 'type', 'url', 'error']

  all_ids.flatten.each do |id|
   
 #   fetch(id, 'marc')
    fetch(id, 'meta')
    @error_array.each {|err| csv << err} if @error_array.count > 0
    @error_array = []
    
    gocount += 1
    puts gocount.to_s + " of " + fullcount + " - id: " + id


    @id = nil
    @status = nil
  end
end
