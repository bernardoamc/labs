# Example from "Working with Ruby Threads"
Order = Struct.new(:amount, :status) do
  def pending?
    status == 'pending'
  end

  def collect_payment
    puts "Collecting payment..."
    self.status = 'paid'
  end
end

order = Order.new(100.00, 'pending')
mutex = Mutex.new

5.times.map do
  Thread.new do
    mutex.synchronize do
      if order.pending?
        order.collect_payment
      end
    end
  end
end.each(&:join)
