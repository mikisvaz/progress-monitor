require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'lib', 'progress-monitor')

def self.loop1
  puts "not monitored"
  100.times { 
    sleep 0.01 
  }
end

def self.loop2
  loop1
  puts "Monitored"
  100.times { 
    sleep 0.01 
  }

end

Progress.monitor("Message", :stack_depth => 1)
puts "not monitored"
100.times { 
  sleep 0.01 
}

loop2

