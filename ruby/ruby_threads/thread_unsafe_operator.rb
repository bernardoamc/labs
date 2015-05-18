require 'thread'

class NotThreadSafe
  def initialize(operations = 2)
    @operations = operations
  end

  def operate
    threads = []

    @operations.times do |i|
      threads << Thread.new do
        puts status = heavy_operation("Thread #{i + 1}")
        results << status
      end
    end

    threads.each(&:join)
  end

  def heavy_operation(return_value)
    return_value
  end

  def results
    sleep 1
    @results ||= Queue.new
  end
end

not_safe = NotThreadSafe.new
not_safe.operate

puts not_safe.results.size
