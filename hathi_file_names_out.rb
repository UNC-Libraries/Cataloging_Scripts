require "csv"

meta = "output/meta_files.csv"
marc = "output/marc_files.csv"


metad = Dir.new("xml_meta")
marcd = Dir.new("xml_marc")

metaf = []
marcf = []


CSV.open(meta, "a") do |csv|
  metad.each do |f|
      csv << [f] unless f[0] == "."
  end
end

CSV.open(marc, "a") do |csv|
  marcd.each do |f|
      csv << [f] unless f[0] == "."
  end
end