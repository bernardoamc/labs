100.times do
  Thread.new { sleep }
end

pid = Process.pid

# This will output 102 threads
# 100 thread above + Thread.main + MRI internal thread
puts %x{ top -l1 -pid #{pid} -stats pid,th }

# Put Thread.main to sleep to avoid finishing it
# and closing all other threads
sleep
