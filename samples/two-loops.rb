require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'lib', 'progress-monitor')

# Each progress meter backs up one line
puts ""
puts ""

Progress.monitor("Main Loop")
(1..100).to_a.each{ 
  Progress.monitor
  (1..100).to_a.each{ 
    sleep 0.05
  }
}

