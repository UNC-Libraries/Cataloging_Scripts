# ruby 1.9
# runs on .mrc file
# usage:
# ruby overlay_on_019.rb

# requires:
# list of 001s from records in catalog
# new .mrc file of records that won't match on 001s,
#   but might match on 019s. Any prefix or suffix required to
#   match with loaded records should be already added to
#   this file.

require "marc"
require "csv"
require "highline/import"

mrcfile = "data/recs.mrc"
valfile = "data/001s.txt"

t = Time.now
timestring = t.strftime("%Y-%m-%d_%H-%M")

log = "output/log_#{timestring}.csv"
errs = [['Source','001 value','Message']]

splitfile = ask("Do you want to split the .mrc file based on how the records match (on 001, 019, or not at all)? y/n")

usesuffix = ask("Does this collection use a suffix on the 001? y/n")


suffix = ask("What's the 001 suffix for this collection? (examples: spr, acs, etc...") if usesuffix == 'y'

existing_001s = []

if File.exist?(valfile)
  File.open(valfile, "r").readlines.each do |ln|
    line = ln.chomp
    if usesuffix == 'y'
      if line.end_with?(suffix)
        existing_001s << line
      else
        errs << ['001 list',line,'001 in catalog missing suffix'] unless line == '001'
        existing_001s << line + suffix
      end
    else
      existing_001s << line
    end
  end
end

if splitfile == 'y'
  match001writer = MARC::Writer.new("output/match_on_001.mrc")
  match019writer = MARC::Writer.new("output/match_on_019.mrc")
  nomatchwriter = MARC::Writer.new("output/no_match.mrc")
else
  marcwriter = MARC::Writer.new("output/edited.mrc")
end

ct_recs = 0
ct_match_001 = 0
ct_match_019 = 0
ct_no_match = 0

MARC::Reader.new(mrcfile).each do |rec|
  ct_recs += 1
  
  match_on_001 = false

  the_001s = rec.fields("001")
  ct_001s = the_001s.count

  if ct_001s != 1
        errs << ['MARC', rec['001'].value, 'A record is either missing an 001 field, or has too many 001 fields.']
  else
    the_001 = rec['001'].value
    the_001.sub!(/^(ocn|ocm|on)/,'')

    if usesuffix == 'y'
      the_001 += suffix
      rec.fields.delete(rec['001'])
      new001 = MARC::ControlField.new('001',the_001)
      rec << new001
    end

    if existing_001s.include? the_001
      match_on_001 = true
      ct_match_001 += 1
    end
  end
  
  match_on_019 = false

  the_019s = rec.fields('019')
  ct_019s = the_019s.count
  
  no_match_019s = []
  match_019 = ''

  if ct_019s > 1
    errs << ['MARC', 'the_001', 'Record has more than one 019 field.']
  elsif ct_019s == 1
    the_019 = rec['019']
    subfield_a = the_019.find_all { |sf| sf.code == 'a' }

    subfield_a.each do |sf|
      if usesuffix == 'y'
        num = sf.value + suffix
      else
        num = sf.value
      end
      
      if existing_001s.include? num
        match_019 = num
        match_on_019 = true
      else
        no_match_019s << num
      end
    end

    rec.fields.delete(rec['019'])

    if match_on_019
      ct_match_019 += 1
      new019 = MARC::DataField.new('019', ' ', ' ', ['a', match_019])
      if no_match_019s.count > 0
        no_match_019s.each do |val|
          new019.append(MARC::Subfield.new('a', val))
        end
      end
      rec << new019
    else
      new019 = MARC::DataField.new('019', ' ', ' ', [])
      if no_match_019s.count > 0
        no_match_019s.each do |val|
          new019.append(MARC::Subfield.new('a', val))
        end
      end
      rec << new019
    end

    if match_on_001 && match_on_019
      errs << ['MARC', the_001, 'Match on both 001 and 019']
    end
  end

  ct_no_match += 1 unless match_on_001 || match_on_019

  if splitfile == 'y'
    if match_on_001
      match001writer.write(rec)
    elsif match_on_019
      match019writer.write(rec)
    else
      nomatchwriter.write(rec)
    end
  else
    marcwriter.write(rec)
  end
end

puts "#{ct_recs} : record in incoming MARC file\n"
puts "#{ct_match_001} : records matching on 001\n"
puts "#{ct_match_019} : records matching on 019\n"
puts "#{ct_no_match} : records with no match\n\n"

if ct_recs != (ct_match_001 + ct_match_019 + ct_no_match)
  puts "WARNING: More output records than input records, indicating weird matching has occurred. See log file.\n\n"
end

if errs.count > 1
  CSV.open(log, 'wb') do |csv|
    errs.each { |r| csv << r }
  end
else
  puts "No warnings or errors written to log.\n"
end
