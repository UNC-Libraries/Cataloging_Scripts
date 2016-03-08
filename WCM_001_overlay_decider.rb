# ruby 2.0
#
# Began working on this and abandoned it, but it may become useful if we ever hear
#  a decision on authority control funding and WCM
# The idea was to programmatically control which WCM records should be loaded to overlay existing
#  records, and which should not.
# INPUT: data/mill_info.txt
# Export info on existing records from Millennium:
#  - 001
#  - ENC LEVL
#  - 042
#  - 040|e
#  - 040|b
#  - bnum
#  - no text qualifier; field delim = tab; repeated field delim = ;

# INPUT: data/recs.mrc
# Records already identified to match existing Mill recs on 001

require 'marc'
require 'csv'

t = Time.now
timestring = t.strftime("%Y-%m-%d_%H-%M")
log = "output/log_#{timestring}.csv"
errs = []

def concatsfs(rec, tag, sf)
  concat_val = ''
  rec.fields(tag).each do |f|
   s = f.find_all { |q| q.code == sf }
   s.each { |v| concat_val += "#{v.value} " }
  end
  return concat_val
end

def score_enc(enc, id)
  enc_worse = ['2', '3', '4', '5', '7', '8', 'K', 'L', 'M', 'J']
  enc_better = [' ', '1', 'I']

  if enc_worse.include?(enc)
    return 0
  elsif enc_better.include?(enc)
    return 1
  else
    errs << "#{id} has weird encoding level. You may want to check and re-split the file."
    return 0
  end
end

millinfo = File.open('data/mill_info.txt', "r").read
lines = millinfo.split(/\n/)
lines.shift

oldrecs = {}

lines.each do |line|
  data = line.split(/\t/)
  key = data.shift.to_sym
  oldrecs[key] = data
end

upgrades = []
downgrades = []
same = []

MARC::Reader.new('data/recs.mrc').each do |rec|
  # get data from new record
  the001 = rec['001'].value
  enc = rec.leader[17]
  auth = 0
  auth = 1 if concatsfs(rec, '042', 'a').include?('pcc')
  rda = 0
  rda = 1 if concatsfs(rec, '040', 'e').include?('rda')
  catlang = concatsfs(rec, '040', 'b')
  catlang = 'eng ' if catlang == ''
  engcat = 0
  engcat = 1 if catlang.include?('eng')
  the773 = rec['773']

  # get data from mill record
  o_enc = oldrecs[the001.to_sym][0]
  o_auth = 0
  o_auth = 1 if oldrecs[the001.to_sym][1].include?('pcc')
  o_rda = 0
  o_rda = 1 if oldrecs[the001.to_sym][2].include?('rda')
  o_catlang = oldrecs[the001.to_sym][3]
  o_catlang = 'eng' if o_catlang == ''
  o_engcat = 0
  o_engcat = 1 if o_catlang.include?('eng')
  o_bnum = oldrecs[the001.to_sym][4]

  enc_score = score_enc(enc, the001) - score_enc(o_enc, o_bnum)
  auth_score = auth - o_auth
  rda_score = rda - o_rda
  engcat_score = engcat - o_engcat

  up = false
  down = false
  nochange = 0
  
  upreason = ''
  downreason = ''

  if enc_score == 1
    up = true
    upreason += 'enc '
  elsif enc_score == -1
    down = true
    downreason += 'enc '
  elsif enc_score == 0
    nochange += 1
  end

  if auth_score == 1
    up = true
    upreason += 'auth '
  elsif auth_score == -1
    down = true
    downreason += 'auth '
      elsif auth_score == 0
    nochange += 1
  end

    if rda_score == 1
    up = true
    upreason += 'rda '
  elsif rda_score == -1
    down = true
    downreason += 'rda '
      elsif rda_score == 0
    nochange += 1
  end

  if engcat_score == 1
    up = true
    upreason += 'engcat '
  elsif engcat_score == -1
    down = true
    downreason += 'engcat '
      elsif engcat_score == 0
    nochange += 1
  end

  if up && down
    errs << "#{the001} was upgraded AND downgraded. Up for: #{upreasons}. Down for: #{downreasons}"
  elsif up
    upgrades << rec
  elsif down
    downgrades << [o_bnum, the773]
  elsif nochange == 4
    same << [o_bnum, the773]
  end
end

if downgrades.size > 0
  dglist = "output/downgrades.csv"
  CSV.open(dglist, 'wb') do |csv|
    downgrades.each {|r| csv << r}
  end
  puts "#{downgrades.size} downgraded records.\n"
else
  puts "0 downgraded records.\n"
end

if same.size > 0
  dglist = "output/no_change_update_773s.csv"
  CSV.open(dglist, 'wb') do |csv|
    same.each {|r| csv << r}
  end
  puts "#{same.size} unchanged records in which to update 773.\n"
else
  puts "0 downgraded records.\n"
end

if errs.count > 0
  CSV.open(log, 'wb') do |csv|
    errs.each { |r| csv << r }
  end
else
  puts "No warnings or errors written to log.\n"
end


puts "Upgraded records: #{upgrades.size}\n"

if upgrades.size > 0
  writer = MARC::Writer.new("output/upgraded_recs.mrc")
  upgrades.each {|rec| writer.write(rec)}
  writer.close
end
