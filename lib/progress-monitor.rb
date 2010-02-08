# Allow the possibility of monitoring the progress of some loop.
# Currently only Array.each and Hash.each are supported, but this should
# be easy to extend.
#
# Author:: Miguel Vazquez Garcia
# License:: MIT
# 

# Tracks the progress of a loop. It holds information about how many
# iterations it has to go through and how many have been executed
# already. Every now and then, it prints the progress report.
class Progress

   module Progress::MonitorableProgress

     def monitorable1(method_name)
       module_eval{ 
         orig_name =  ('orig_' + method_name.to_s).to_sym
         
         eval "alias #{ orig_name } #{ method_name }"

         define_method(method_name) do |&block|
           if Progress.active?
             progress_meter = Progress.add_progress_meter(self.monitor_size) if Progress.monitor?
             announcement   = Progress.get_announcement                      if Progress.announce?

             monitor_step = nil unless defined? monitor_step

             res = self.send(orig_name.to_sym) {|v| 
               progress_meter.tick(monitor_step)               if progress_meter 
               Progress.print_announcement(announcement.call(v))         if announcement
               block.call(v) 
             }
             
             Progress.remove_last_meter
             res
           else
             self.send(orig_name.to_sym) {|v| block.call(v)}
           end
         
         end
       }
     end

     def monitorable2(method_name)
       module_eval{ 
         orig_name =  ('orig_' + method_name.to_s).to_sym
         
         eval "alias #{ orig_name } #{ method_name }"
         
         define_method(method_name) do |&block|
           if Progress.active?
             progress_meter = Progress.add_progress_meter(self.monitor_size) if Progress.monitor?
             announcement   = Progress.get_announcement                      if Progress.announce?
             
             monitor_step = nil unless defined? monitor_step

             res = self.send(orig_name.to_sym) {|v1,v2| 
               progress_meter.tick(monitor_step) if progress_meter 
               Progress.print_announcement(announcement.call(v1,v2))         if announcement
               block.call(v1,v2);
             }
             
             Progress.remove_last_meter
             res
           else
             self.send(orig_name.to_sym) {|v1,v2| block.call(v1,v2) }
           end
         
         end
       }
     end
   end


   @@progress_meters = Array.new
   def self.progress_meters
     @@progress_meters
   end
   
   def self.caller_info(callers, depth = 0)
     return [nil, nil] if callers.length <= depth

     line = callers[depth]
     if line.match(/(.*):\d+(?::in `(.*)')/)
       return [$1, $2]
     end

     if line.match(/(.*):\d+/)
       return [$1, nil ]
     end

     info
   end

   @@monitor  = false
   @@announce = false

   def self.process_options(options)
     @@stack_depth = options[:stack_depth] 
     @@skip        = options[:skip] || 0

     if options[:announcement]
       @@announce     = true
       @@announcement = options[:announcement]
     end
   end

   # This function will activate monitoring of the next _supported_ loop.
   #
   # If a description is given as a parameter it will show at the
   # beginning of the progress report.
   def self.monitor(desc = "", options = {})
     @@monitor     = true
     @@desc        = desc
     @@num_reports = options[:num_reports] || 100
     @@call_info   = caller_info(caller)
     process_options(options)
   end

   def self.announce(announcement, options = {})
     @@announce     = true
     @@call_info   = caller_info(caller)
     @@announcement = announcement
     process_options(options)
   end

   def self.get_announcement
     @@announce    = false
     @@announcement
   end

   def self.this_loop?
     if @@stack_depth != nil
       call_info = caller_info(caller, @@stack_depth + 2)
       return false if call_info != @@call_info
     end

     if @@skip > 0
       @@skip -= 1
       return false
     else
       return true
     end
   end

   # Returns true if next loop must be monitored.
   #
   def self.monitor?
     return @@monitor
   end

   def self.announce?
     return @@announce
   end

   def self.active?
     return (monitor? || announce?) && this_loop?
   end

   def self.add_progress_meter(max)
     progress_meter = self.new(max, progress_meters.size)

     progress_meters.push(progress_meter)

     progress_meter
   end

   def self.remove_last_meter
     progress_meters.pop
   end

   # Creates a new instance. Max is the total number of iterations of the
   # loop. The depth represents how many other loops are above this one,
   # this information is used to find the place to print the progress
   # report.
   #
   def initialize(max,depth)
     @max = max
     @max = 1 if @max < 1
     @current = 0
     @time = Time.now
     @last_report = -1
     @num_reports = @@num_reports
     @depth = depth
     @desc = @@desc
     @@monitor = false
   end

   # Used to register a new completed loop iteration.
   #
   def tick(step = nil)

     if step.nil?
       @current += 1
     else
       @current = step
     end

     percent = @current.to_f/ @max.to_f
     if percent - @last_report > 1.to_f/@num_reports.to_f 
       report
       @last_report=percent
     end

     nil
   end

   # Prints de progress report. It backs up as many lines as the meters
   # depth. Prints the progress as a line of dots, a percentage, time
   # spent, and time left. And then goes moves the cursor back to its
   # original line. Everything is printed to stderr.
   #
   def report

     percent = @current.to_f/ @max.to_f
     percent = 0.001 if percent < 0.001
     if @desc != ""
       indicator = @desc + ": "
     else
       indicator = "Progress "
     end
     indicator += "["
     10.times{|i|
       if i < percent * 10 then
         indicator += "."
       else
         indicator += " "
       end
     }
     indicator += "]   done #{(percent * 100).to_i}% "

     eta =  (Time.now - @time)/percent * (1-percent)
     eta = eta.to_i
     eta = [eta/3600, eta/60 % 60, eta % 60].map{|t| t.to_s.rjust(2, '0')}.join(':')

     used = (Time.now - @time).to_i
     used = [used/3600, used/60 % 60, used % 60].map{|t| t.to_s.rjust(2, '0')}.join(':')

     indicator += " (Time left #{eta} seconds) (Started #{used} seconds ago)"

     $stderr.print("\033[#{@depth + 1}F\033[2K" + indicator + "\033[#{@depth + 1}E")
   end

   def self.print_announcement(message = nil)
     return if message.nil?
     total_depth = @@progress_meters.length + 1
     $stderr.print("\033[#{total_depth}F\033[2K" + message + "\033[#{total_depth}E")
   end
end

class Integer
  class << self
    include Progress::MonitorableProgress
  end

  def monitor_size
    self
  end

  self.monitorable1(:times)
end

class Array
  class << self
    include Progress::MonitorableProgress
  end

  def monitor_size
    self.length
  end

  self.monitorable1(:each)
  self.monitorable1(:collect)
end



class Hash
  class << self
    include Progress::MonitorableProgress
  end

  def monitor_size
    self.length
  end

  self.monitorable2(:each)
  self.monitorable2(:collect)
end

class File
  class << self
    include Progress::MonitorableProgress
  end

  def monitor_size
    self.stat.size
  end

  def monitor_step
    self.pos
  end

  self.monitorable1(:each)
  self.monitorable1(:collect)
end



