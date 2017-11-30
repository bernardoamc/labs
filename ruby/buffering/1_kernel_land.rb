def normal
  f = File.open("1_kernel_land.txt", "w")

  10.times do |i|
    sleep 1
    f.write "#{i}-"
  end

  f.close
end

def with_syswrite
  f = File.open("1_kernel_land.txt", "w")

  10.times do |i|
    sleep 1
    f.syswrite "#{i}-"
  end

  f.close
end

def with_sync
  # https://github.com/ruby/ruby/blob/defcaf89dd9ed860f8ac00508ff80bcde86645a1/file.c#L6419
  f = File.open("1_kernel_land.txt", "w", File::SYNC)

  10.times do |i|
    sleep 1
    f.syswrite "#{i}-"
  end

  f.close
end

#normal
with_syswrite
#with_sync
