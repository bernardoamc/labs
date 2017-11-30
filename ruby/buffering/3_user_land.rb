f = File.new("3_user_land.txt", "w")

f.sync = true

f.write "First\n"
f.syswrite "Last\n"

f.close
