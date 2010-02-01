require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'lib', 'progress-monitor')

# Skip first loop
puts ""

Progress.monitor("Main Loop",100, 1)

puts "This loop must not be monitored"
puts
(1..100).to_a.each{ 
  sleep 0.05
}

puts "This loop must be monitored"
puts
(1..100).to_a.each{ 
    sleep 0.05
}

