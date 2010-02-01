require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'lib', 'progress-monitor')

Progress.monitor
10.times{|i|
  sleep 1
}

