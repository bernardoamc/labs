require 'benchmark/ips'

puts $stdout.sync

def normal
  $stdout.sync = true
  50_000.times do |i|
    $stdout.write "line-#{i}"
  end
end

def without_sync
  $stdout.sync = false
  50_000.times do |i|
    $stdout.write "line-#{i}"
  end
end
=begin
Benchmark.ips do |x|
  x.report("normal: ") { normal }
  x.report("without_sync: ") { without_sync }

  x.compare!
end
=end
