#! /usr/bin/env ruby
# Genereer een oefenblad met alle maal- en deeltafels
# van de opgegeven cijfers, in willekeurige volgorde

# Lijst met de gewenste maaltafels
tafels = [2, 10]

# Lijst met alle gegenereerde oefeningen
maaltafels = []
deeltafels = []

tafels.each do |x|
  1.upto(10) do |y|
    maaltafels << "%3d × %2d = \n" % [y, x]
    deeltafels << "%3d : %2d = \n" % [x*y, x]
  end
end

# Eerst maaltafels, dan deeltafels
#puts maaltafels.shuffle
#puts deeltafels.shuffle

# Alle oefeningen door elkaar
puts (maaltafels + deeltafels).shuffle
