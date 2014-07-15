# ruby 1.9
# runs on .mrc file

require "marc"

exit if Object.const_defined?(:Ocra)

# Set files
mrcfile = 'data/797input.mrc'
outfile = 'output/797data.txt'

# Read in MARC input files
@recs = []
MARC::Reader.new(mrcfile).each {|rec| @recs << rec}

# Set up format for output
@lines = []
@lines << ['001', 'whole field', 'flag', 'e', 'needs review']

@recs.each do |rec|
  # Get 001 value for each record
  if rec['001'].value
    v001 = rec['001'].value
  else
    v001 = ""
  end

  # Look at each 797 field
  rec.each_by_tag('797') do |the797|
    # Write whole field to a string, for reference
    vs797 = the797.to_s
    # Set/empty counters
    ct9 = 0
    cte = 0
    # Create array to hold any $e values
    alle = []
    # Then, look at each subfield in that 797...
    the797.each do |sf|
      # count $9s
      ct9 += 1 if sf.code == '9'
      if sf.code == 'e'
        # count $es
        cte += 1
        # Send normalized (spaces, commas, periods removed) $e values to array
        alle << sf.value.gsub(/\s*[.,]\s*$/, '')
      end
    end
    # Set flags based on subfield counts
    flag = ""
    flag = "No $9 AND No $e" if ct9 == 0 && cte == 0
    flag = "Has $9, No $e" if ct9 > 0 && cte == 0
    flag = "More than one $e - split into separate fields" if cte > 1

    # If there are no $es, send one line per 797 to output list
    @lines << [v001, vs797, flag, "", ""] if cte == 0
    # If there is 1 or more $e, send one line per $e to output list
    if cte > 0
      alle.each do |e|
        @lines << [v001, vs797, flag, e, ""]
      end
    end
  end
end

# Write output list to output file, tab delimited
File.open outfile, "wb" do |out|
  @lines.each do |line|
    puts line.inspect
    line_string = line.join("\t")
    out.puts line_string
  end
end

exit
