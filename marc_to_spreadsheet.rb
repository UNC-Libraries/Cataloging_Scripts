#require 'rubygems'
require "marc"
require "marc_extended"
require "highline/import"

marcfile = ARGV[0]
outpath = ARGV[1]

print "Reading marcfile..."
marcrecs = []
MARC::Reader.new(marcfile).each {|rec| marcrecs << rec }
print "#{marcrecs.size} records."

outfile = File.new(outpath, "w")

$option = ""

class MainMenu
  def initialize
    puts "How specific are we going to break this data down?"
    choose do |menu|

      menu.choice :one_field_per_row do
        $option = "field"
      end

      menu.choice :one_subfield_per_row do
        $option = "subfield"
      end
    end
  end
end

MainMenu.new

if $option == "field"
  outfile.puts "rec id\tfield tag\toccurrence\ti1\ti2\tfield data"
  marcrecs.each do |rec|
    the001 = rec._001
    thetags = rec.tags
    outfile.puts "#{the001}\tLDR\t1\t \t \t#{rec.leader}"
    thetags.each do |tag|
      counter = 1
      thefields = rec.find_all {|f| f.tag == tag}
      thefields.each do |f|
        if tag.match(/^00/)
          outfile.puts "#{the001}\t#{f.tag}\t#{counter}\t \t \t#{f.to_s.gsub(/^....(.*)/,'\1')}"
        else
          outfile.puts "#{the001}\t#{f.tag}\t#{counter}\t#{f.indicator1}\t#{f.indicator2}\t#{f.to_s.gsub(/^.......(.*)/,'\1')}"
        end
        counter += 1
      end
    end
  end
    
elsif $option == "subfield"
  outfile.puts "rec id\tfield tag\tfield occurrence\tfield id\ti1\ti2\tsubfield code\tsubfield order\tsubfield data"
  marcrecs.each do |rec|
    the001 = rec._001
    thetags = rec.tags

    ldr = rec.leader
    ldr_byte = 0
    ldr.each_char do |c|
      outfile.puts "#{the001}\tLDR\t1\tLDR-001\t \t \t#{ldr_byte}\t#{ldr_byte}\t#{c}"
      ldr_byte += 1
    end

    thetags.each do |tag|
      tag_counter = 1
      thefields = rec.find_all {|f| f.tag == tag}
      thefields.each do |f|
        padded_tag_ct = "%03d" % tag_counter
        field_id = "#{f.tag}-#{padded_tag_ct}"
        if tag.match(/^00[678]/)
          byte_pos = 0
          f.value.each_char do |c|
            outfile.puts "#{the001}\t#{f.tag}\t#{tag_counter}\t#{field_id}\t \t \t#{byte_pos}\t#{byte_pos}\t#{c}"
            byte_pos += 1
          end
        elsif tag.match(/^00[^678]/)
          outfile.puts "#{the001}\t#{f.tag}\t#{tag_counter}\t#{field_id}\t \t \t \t \t#{f.value}"
        else
          subfield_ct = 1
          f.each do |sf|
            outfile.puts "#{the001}\t#{f.tag}\t#{tag_counter}\t#{field_id}\t#{f.indicator1}\t#{f.indicator2}\t#{sf.code}\t#{subfield_ct}\t#{sf.value}"
            subfield_ct += 1
          end
        end
        tag_counter += 1
      end
    end
  end
else
  puts "Unknown option"
end

outfile.close
