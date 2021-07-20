# Run with puma
#
# $ puma
# -t <threads> -> 16 threads by default
# -w <workers>

sleeper = Proc.new do |_env|
  # sleep(0.25) - Just sleeps the thread
  wait_until = Time.now + 0.25

  until Time.now > wait_until
    # do nothing
  end

  [200, {}, ["Hello World"]]
end

run sleeper
