module Progress
  class Progress::Bar

    # Creates a new instance. Max is the total number of iterations of the
    # loop. The depth represents how many other loops are above this one,
    # this information is used to find the place to print the progress
    # report.
    #
    def initialize(max,depth, num_reports, desc)
      @max = max
      @max = 1 if @max < 1
      @current = 0
      @time = Time.now
      @last_report = -1
      @num_reports = num_reports
      @depth = depth
      @desc = desc
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

      STDERR.print("\033[#{@depth + 1}F\033[2K" + indicator + "\n\033[#{@depth + 2}E")
    end
  end
end


