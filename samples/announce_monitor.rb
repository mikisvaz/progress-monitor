# This is an example using a hash. It also shows what happens when you
# print stuff. In this case, we print new lines, and the progress meter
# is always moved to the line above the last one.

require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'lib', 'progress-monitor')

h = Hash.new

('a'..'z').to_a.each{|l|
  h[l] = l.upcase
}

Progress.monitor("hash",:num_reports => 5, :announcement => Proc.new {|d,u| "Downcase #{d}, uppercase #{u}" } )
h.each{|d,u|
  sleep(0.2)
}
