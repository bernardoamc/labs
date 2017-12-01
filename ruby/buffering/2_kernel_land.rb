require 'benchmark/ips'

@f1 = File.open("1_kernel_land.txt", "w")
@f2 = File.open("2_kernel_land.txt", "w")
@f3 = File.open("3_kernel_land.txt", "w")
@f4 = File.open("4_kernel_land.txt", "w")

# Buffering in both layers
def normal
  50_000.times do |i|
    @f1.write "line-#{i}"
  end
end

# Buffering only in kernel
def with_syswrite
  50_000.times do |i|
    @f2.syswrite "line-#{i}"
  end
end

# Buffering only in kernel
def with_sync
  @f3.sync = true
  50_000.times do |i|
    @f3.write "line-#{i}"
  end
end

# No buffer whatsoever
def with_fsync
  50_000.times do |i|
    @f4.syswrite "line-#{i}"
    @f4.fsync
  end
end

Benchmark.ips do |x|
  x.report("normal: ") { normal }
  x.report("with_syswrite: ") { with_syswrite }
  x.report("with_sync: ") { with_sync }
  x.report("with_fsync: ") { with_fsync }

  x.compare!
end

@f1.close
@f2.close
@f3.close
@f4.close
