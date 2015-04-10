# ruby 1.9
# runs on .mrc file
# usage:
# ruby extract_by_field_value.rb

# requires:
# list of 001s from records in catalog
# new .mrc file of records that won't match on 001s,
#   but might match on 019s. Any prefix or suffix required to
#   match with loaded records should be already added to
#   this file.

require "marc"

mrcfile = "data/recs_to_be_loaded.mrc"
valfile = "data/001_list.txt"

existing_001s = []

File.open(valfile, "r").readlines.each { |ln| existing_001s << ln.chomp }

matchwriter = MARC::Writer.new("data/match_on_019.mrc")
nomatchwriter = MARC::Writer.new("data/no_matches.mrc")

MARC::Reader.new(mrcfile).each do |rec|
  match_value = false
  not_the_one = []
  the_one = ''

  if rec['019']
    the_019 = rec['019']
    subfield_a = the_019.find_all { |sf| sf.code == 'a' }

    subfield_a.each do |sf|
      num = sf.value
      if existing_001s.include? num
        the_one = num
        match_value = true
      else
        not_the_one << num
      end
    end

    if match_value
      rec.fields.delete(rec['019'])
      new019 = MARC::DataField.new('019', '', '', ['a', the_one])
      if not_the_one.count > 0
        not_the_one.each do |val|
          new019.append(MARC::Subfield.new('a', val))
        end
      end
      rec << new019
      matchwriter.write(rec)
    else
      nomatchwriter.write(rec)
    end
  else
    nomatchwriter.write(rec)
  end
end
