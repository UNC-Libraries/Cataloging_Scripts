x = []
nx = []

d = Dir.new("xml_meta")

d.each do |f|
  unless f[0] == "."
    fl = File.open("xml_meta/#{f}", "r").readline

    if fl.start_with?("<?xml")
      x << f
    else
      nx << f
    end
  end
end

puts nx.size