require 'csv'
require 'marc'
require 'nokogiri'

marcfile = 'data/print_marc.mrc'
idfile = 'data/id_bnum_vol_all.csv'
metadir = 'xml_meta/'
marcxml = 'output/mushed_marc.xml'

@marchash = {}

reader = MARC::Reader.new(marcfile)
reader_array = []
reader.each {|rec| reader_array << rec}

@reader_ct = reader_array.count
puts "Records in MARC file: " + @reader_ct.to_s

def print_r(text, size=80)
  print "\r#{text.ljust(size)}"
  STDOUT.flush
end

@done_ct = 0
@step = @reader_ct / (@reader_ct * 0.01)
puts "Ingesting and processing original MARC:\n"

reader_array.each do |rec| 
  tags = rec.tags
  
  # Get bnum from 907 and format
  bnum = rec['907']['a'][1..8]
#  puts bnum
#.b12784023
  # Get OCLC number from 001 and format
  orig001 = rec['001'].value
  norm001 = orig001.gsub(/oc[mn]0*/, '')

  # If OCLC number in 001 is NOT already in an 035, add
  # the formatted OCLC number to an 035.
  vals_in_035 = []
  if tags.include?("035")
    # get all 035 values, minus \(.*\)  
    the035s = rec.find_all {|f| ('035') === f.tag}
    the035s.each do |field|
      field.each {|subfield| vals_in_035 << subfield.value.gsub(/\(.*\)/, '')}
    end
  end

  unless vals_in_035.include? (norm001)
    rec << MARC::DataField.new('035', ' ', ' ', ['a', '(OCoLC)' + norm001])
  end

  # Now that 035s are set, delete existing 001
  # Replace it with bnum
  rec.fields.delete(rec['001'])
  rec << MARC::ControlField.new('001', value = bnum)
  
  # Remove OCLC 003 if it exists and insert NcU 003 to
  # identify source of 001
  rec.fields.delete(rec['003']) if tags.include?("003")
  rec << MARC::ControlField.new('003', value = "NcU")

  # Index recs in hash for lookup
  @marchash[bnum] = rec

  # progress display
  @done_ct += 1
  if @done_ct % @step == 0
    print_r(
      "%d of %d (%d%%)" %
      [@done_ct, @reader_ct, (@done_ct.to_f/@reader_ct * 100)]
    )
  end
end



# read in IA id, 8 digit bnum, and volume info
id_data = CSV.read(idfile)
id_data.shift

@done_ct = 0
@id_ct = id_data.count
@step = @id_ct / (@id_ct * 0.01)
puts "\nGathering pieces for Hathi records:\n"

# array to gather pieces of data that will be used to
# create hathi recs
hrec_data = []

id_data.each do |id|
  # open meta file
  f = File.open("#{metadir}#{id[0]}.xml")

  # Create hash to hold pieces
  begin
    h = {:iaid => id[0],
    :ibnum => id[1],
    :vol => id[2],
    :orec => @marchash[id[1]].to_marchash,
    :meta => Nokogiri::XML(f),
    :ark => ""
  }
  rescue
    puts "\nproblem with #{id[0]}, #{id[1]}\n"
  end
  #close opened meta file
  f.close

  hrec_data << h

  # progress display
  @done_ct += 1
  if @done_ct % @step == 0
    print_r(
      "%d of %d (%d%%)" %
      [@done_ct, @id_ct, (@done_ct.to_f/@id_ct * 100)]
    )
  end
end

@marchash = {}

# Process pieces and create new marc rec
to_write = []

@done_ct = 0
@hrec_ct = hrec_data.count
@step = @hrec_ct / (@hrec_ct * 0.01)
puts "Processing Hathi records:\n"

hrec_data.each do |h|
#  puts "#{h[:iaid]}, #{h[:ibnum]}, #{h[:vol]}"
  h[:vol] = nil if h[:vol] == "-"
  h[:ark] = h[:meta].xpath("//identifier-ark")[0].to_s.gsub(/<\/?identifier-ark>/, "")

  sfs955 = [['b', h[:ark]], ['q', h[:iaid]]]
  sfs955 << ['v', h[:vol]] if h[:vol]
  the955 = ["955", " ", " ", sfs955]

  h[:orec]['fields'] << the955
  h[:orec]['fields'].sort!
  
  to_write << MARC::Record.new_from_marchash(h[:orec])

  # progress display
  @done_ct += 1
  if @done_ct % @step == 0
    print_r(
      "%d of %d (%d%%)" %
      [@done_ct, @hrec_ct, (@done_ct.to_f/@hrec_ct * 100)]
    )
  end
end

puts "Writing MARC XML file"
puts to_write.count
writer = MARC::XMLWriter.new(marcxml)
to_write.each {|rec| writer.write(rec)}
writer.close

puts "Done!"
