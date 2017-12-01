def normal
  f = File.open("1_kernel_land.txt", "w")

  10.times do |i|
    sleep 1
    f.write "#{i}-"
  end

  f.write "\n"
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

puts "Normal write"
normal
puts "With syswrite"
with_syswrite
