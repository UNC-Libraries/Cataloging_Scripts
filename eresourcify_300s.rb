file = ARGV[0]
file_lines = IO.readlines(file)

@new_lines = []

def output(string)
  string = string
  @new_lines << string
end

fix = 0

file_lines.each do |ln|
  if ln.match(/^=300  /)
    #puts ln
    ln.gsub!(/\.\./, '.')


    if ln.match(/^=300  \\\\\$a((.*([^:]|[^ ]:)\$b)|([^$]*(ill|map|port))|(.*([^;]|[^ ];)\$c)|(.*\$b[^$]*(\d| )cm))/)
      @new_lines << ln + " %%%fixme\n"
      fix += 1
    elsif ln.match(/online resource/)
      output(ln)

    # $ap. cm.
    # $ap., cm.
    # $ap.
    elsif ln.match(/\$a[pv]\.,? *(?:cm\.)? *$/)
      ln.gsub!(/^(=300  \\\\\$a).*/, '\11 online resource.')
    else
     ln.gsub!(/^(=300.*) *;\$c.*$/, '\1')


     ln.gsub!(/(=300.*\$a)(.*?)( *$| *:\$b)/, '\11 online resource (\2)\3')
      @new_lines << ln
#      puts "#{ln}\n\n"
     
    end
    
  else
    output(ln)
  end

end

out = File.open('data/300s.mrk', "w") do |f|
  @new_lines.each {|l| f.write(l)}
end

puts "#{fix} need to be manually corrected. Then script can be run again."
