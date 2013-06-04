require 'rubygems'
require 'fastercsv'


puts "\n\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
puts "SerialsSolutions Solutions presents...".center(42)
puts "DUPE DEDUPER".center(42)
puts "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
puts "For detailed instructions on how to use this script, visit the Staff Wiki:"
puts "Technical Services >> E-Resources & Serials Management >> E-Resource"
puts "Cataloging >> (How to... -> Use other tools ->) In-house Ruby scripts"

puts "\n\n"
puts "Please enter the load date in the following format: YYYYMM"
puts "Example (August 2010) = 201008"
loaddate = gets.chomp
#loaddate = 201009

master = FasterCSV.read('data/master_dupe_list.csv', :headers => true)
#p master
new_dupes = FasterCSV.read('data/new_dupes.csv', :headers => true)
#p new_dupes

known_bnums = []
known_oclc = []
known_ssjs = []

lines_to_write = []
new_unique_lines = 0
known_lines = 0
all_new_lines = 0

puts "Ingesting master dupe list data..."

master.each do |row|  
#  puts "reading master row"
  known_bnums.push(row['bnum']) if row ['bnum']
  known_ssjs.push(row['ssj']) if row ['ssj']
  known_oclc.push(row['oclc num']) if row ['oclc num']
  known_lines += 1
end #sent_dupes.each do |row|
    
puts "\n\nAfter processing master dupes:"
puts "Known bnums #{known_bnums.size.to_s}"
#p known_bnums
puts "Known oclc #{known_oclc.size.to_s}"
#p known_oclc
puts "Known ssjs #{known_ssjs.size.to_s}"
#p known_ssjs

puts "\n\nChecking new dupes against master file..."
new_dupes.each do |row|
  all_new_lines += 1
  puts "READING ROW #{all_new_lines + 1}"
  a_match = false
  match_score = 0
#  puts "initial match score: #{match_score}"
  
  if row['bnum']
    if known_bnums.include?(row['bnum'])
      match_score += 1 
      puts "-----match on bnum"
    end
  end

  if row['ssj']
    if known_ssjs.include?(row['ssj'])
     match_score += 1 
     puts "-----match on ssj"
    end
  end

  if row['oclc num']
    if known_oclc.include?(row['oclc num'])
     match_score += 1 
     puts "-----match on oclc num"
    end
  end

  if match_score == 0
  puts "-------------------------------------UNIQUE!"
    write_row = [loaddate, row['bnum'], row['ssj'], row['oclc num'], row['title'], row['other problems'], row['dupe format'],
                 row['replacement oclc num'], row['encoding level'], row['lccn'], row['authentication code'], row['issn'], 'No']
    lines_to_write.push(write_row)
    new_unique_lines += 1
  end #if match_score == 0
end #new_dupes.each do |row|

FasterCSV.open('data/add_to_master_dupe_list.csv', "w") do |csv|
  csv << write_row = ['load date', 'bnum', 'ssj', 'oclc num', 'title', 'other problems', 'dupe format',
                      'replacement oclc num', 'encoding level', 'lccn', 'authentication code', 'issn', 'sent to sersol?']
  lines_to_write.each do |line|    
    csv << line    
  end #new_dupes.each do |dupe|
end #FasterCSV.open('data/sara_sersol/unique_new_dupes.csv', "w") do |csv|

puts "\n\nDONE!"
puts "Unique new records identified: #{new_unique_lines} of #{all_new_lines}"
puts "Dupe records ignored: #{all_new_lines - new_unique_lines}"

puts "\n\nNEXT STEP..."
puts "Manually copy new unique dupes from add_to_master_dupe_list.csv to master_dupe_list.csv"
