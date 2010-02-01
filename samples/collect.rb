require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'lib', 'progress-monitor')

dc = ('a'..'z').to_a
Progress.monitor
uc = dc.collect{|l|
  sleep(0.2)
  l.upcase
}
p uc

