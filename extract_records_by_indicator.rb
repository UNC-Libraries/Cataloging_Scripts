require 'rubygems'
require 'fastercsv'
require 'setup'


timer = Timer.new
timer.time("Done!") do
  
  reader = MARC::Reader.new(ARGV[0])
  
  second_ind_0 = []
  reader.each do |rec|
    title_field = rec.getField('245')[0]
    if title_field.indicator2 == '0'
      #the907 = rec.getField('907')[0]
      bibnum = rec.getField('907')[0].getSubfield('a').value.match(/b\d*\w?/)[0]
      tp = title_field.getSubfield('a').value
      second_ind_0.push([bibnum, tp])
    end #if title_field.indicator2 == '0'
  end #reader.each do |rec|
    
    to_output = []
    second_ind_0.each do |e|
      $initial_articles.each do |art|
        to_output.push(e) if e[1].match(/^#{art}/i)
        end #$initial_articles.each do |art|
      end #second_ind_0.each do |e|
  
  FasterCSV.open('data/second_ind_zero.csv', "w") do |csv|
    csv << write_row = ['bibnum', 'title proper']
    to_output.each do |line| 
      csv << line    
    end #new_dupes.each do |dupe|
  end #FasterCSV.open('data/sara_sersol/unique_new_dupes.csv', "w") do |csv|
  
end #timer