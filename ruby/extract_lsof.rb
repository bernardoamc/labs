port = 3000
puts `lsof -i tcp:#{port} | grep ruby | tr -s " " | cut -d" " -f2`
puts $?.exitstatus
