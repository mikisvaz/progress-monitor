require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'lib', 'progress-monitor')

f = File.open('README.rdoc')
Progress.monitor("File.each")
f.each{|l|
  sleep(1)
}
