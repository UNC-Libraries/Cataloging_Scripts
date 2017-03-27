#$LOAD_PATH << '.'
require 'marc'
#require 'marc_record'

infile = ARGV[0]

outfile = File.open('output/bad_encoding_fields.txt', 'a+b')
outfile << "filename	record id	rec_enc (LDR/09)	field_encoding	marc tag	data\n"

reader = MARC::Reader.new(infile).each { |rec|
  recid = rec['001'].value
  charenc = rec.leader[9]
  rec.fields.each { |f|
    if f.is_a? MARC::DataField
      strf = f.to_s
      m = strf.match(/^(...)(.*)/)
      tag = m[1]
      data = m[2]
      outfile << "#{infile}	#{recid}	#{charenc}	#{data.encoding.inspect}	#{tag}	#{data}\n"
    end
  }
}

outfile.close
