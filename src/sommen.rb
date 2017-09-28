#! /usr/bin/env ruby
#
# Maak een lijstje in willekeurige volgorde van alle 
# sommen met een "brug", vb 8+5, 14-6, ....
sommen = []

2.upto(9) do |x|
  lo = 10 - x + 1
  lo.upto(9) do |y|
    sommen << "#{x} + #{y} =\t____\n"
  end
end

11.upto(19) do |x|
  lo = x - 10 + 1
  lo.upto(9) do |y|
    sommen << "#{x} - #{y} =\t____\n"
  end
end

puts sommen.shuffle
