require 'benchmark/ips'

@f1 = File.open("1_kernel_land.txt", "w")
@f2 = File.open("2_kernel_land.txt", "w")

def normal
  50_000.times do |i|
    @f1.write "line-#{i}"
  end
end

def without_sync
  50_000.times do |i|
    @f2.syswrite "line-#{i}"
  end
end

def with_sync
  50_000.times do |i|
    @f3.syswrite "line-#{i}"
  end
end

Benchmark.ips do |x|
  x.report("normal: ") { normal }
  x.report("without_sync: ")   { without_sync }

  x.compare!
end

@f1.close
@f2.close

@f2 = File.open("2_kernel_land.txt", "w")
# https://github.com/ruby/ruby/blob/defcaf89dd9ed860f8ac00508ff80bcde86645a1/file.c#L6419
@f3 = File.open("3_kernel_land.txt", "w", File::SYNC)

Benchmark.ips do |x|
  x.report("without_sync: ") { without_sync }
  x.report("with_sync: ")   { with_sync }

  x.compare!
end

@f2.close
@f3.close
