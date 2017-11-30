f = File.new("2_user_land.txt", "w")

f.write "First\n"
f.flush
f.syswrite "Last\n"

f.close
