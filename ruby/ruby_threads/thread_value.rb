thread = Thread.new do
  400 + 5
end

# Waits the thread to finish its work and get the last evaluated line
puts thread.value #=> 405
