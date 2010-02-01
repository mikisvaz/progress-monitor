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

  @@monitor = false
  @@desc = ""
  @@skip = 0

  # This function will activate monitoring of the next _supported_ loop.
  #
  # If a description is given as a parameter it will show at the
  # beginning of the progress report.
  def self.monitor(desc = "", num_reports = 100, stack_depth = nil, skip = 0)
    @@monitor = true
    @@desc = desc
    @@num_reports=num_reports
    @@call_info = caller_info(caller)
    @@stack_depth = stack_depth 
    @@skip = skip
  end

  # Returns true if next loop must be monitored.
  #
  def self.active?

    return false unless @@monitor

    if @@stack_depth != nil
      call_info = caller_info(caller, @@stack_depth + 1)
      return false if call_info != @@call_info
    end

    if @@skip > 0
      @@skip -= 1
      return false
    else
      return true
    end
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
    @last_report = 0
    @num_reports = @@num_reports
    @depth = depth
    @desc = @@desc
    @@monitor = false
    report
  end

  # Used to register a new completed loop iteration.
  #
  def tick(steps = 1)
    @current += steps
    percent = @current.to_f/ @max.to_f
    if percent - @last_report > 1.to_f/@num_reports.to_f then
      report
      @last_report=percent
    end
  end

  def set(step)
    @current = step
    percent = @current.to_f/ @max.to_f
    if percent - @last_report > 1.to_f/@num_reports.to_f then
      report
      @last_report=percent
    end
 
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

    $stderr.print("\033[#{@depth + 1}F\033[2K" + indicator + "\033[#{@depth + 1}E"  )

  end


end

class Integer
  alias :orig_times :times

  def times (&block)
    if Progress.active?  then
      progress_meters = Progress::progress_meters
      progress_meters.push(Progress.new(self, progress_meters.size ))
      orig_times {|w|block.call(w);progress_meters.last.tick;}
      progress_meters.pop
    else
      orig_times &block
    end
  end
end



class Array
  alias :orig_each :each

  def each (&block)
    if Progress.active?  then
      progress_meters = Progress::progress_meters
      progress_meters.push(Progress.new(self.length, progress_meters.size ))
      orig_each {|w|block.call(w);progress_meters.last.tick;}
      progress_meters.pop
    else
      orig_each &block
    end
  end

  alias :orig_collect :collect
  def collect (&block)
    if Progress.active?  then
      progress_meters = Progress::progress_meters
      progress_meters.push(Progress.new(self.length, progress_meters.size ))
      res = orig_collect {|w| r = block.call(w);progress_meters.last.tick; r}
      progress_meters.pop
      res
    else
      orig_collect &block
    end
  end
end



class Hash
  alias :orig_each :each
  def each (&block)
    if Progress.active?  then
      progress_meters = Progress::progress_meters
      progress_meters.push(Progress.new(self.length, progress_meters.size ))
      orig_each {|k,v|block.call(k,v);progress_meters.last.tick;}
      progress_meters.pop
    else
      orig_each &block
    end
  end

end





class File
  alias :orig_each :each
  alias :orig_collect :collect
  def each (&block)
    if Progress.active?  then
      progress_meters = Progress::progress_meters
      progress_meters.push(Progress.new(self.stat.size, progress_meters.size ))
      orig_each {|l| block.call(l);progress_meters.last.set(self.pos);}
      progress_meters.pop
    else
      orig_each &block
    end
  end

  def collect (&block)
    if Progress.active?  then
      progress_meters = Progress::progress_meters
      progress_meters.push(Progress.new(self.stat.size, progress_meters.size ))
      res = orig_collect {|l| r = block.call(l);progress_meters.last.set(self.pos); r}
      progress_meters.pop
      res
    else
      orig_collect &block
    end
  end


end



