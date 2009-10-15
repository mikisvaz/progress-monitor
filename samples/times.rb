require File.join(File.dirname(File.dirname(__FILE__)), 'lib', 'progress-monitor')

Progress.monitor
10.times{|i|
  sleep 1
}

