f = File.new("1_user_land.txt", "w")

f.write "First\n"
f.syswrite "Last\n"

f.close
