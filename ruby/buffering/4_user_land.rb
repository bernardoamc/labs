# Run this example
#$ ruby 4_user_land.rb &> echo

#                  true          false
#               ------------- --------------
# $stdout.tty?  line-buffered block-buffered
# $stderr.tty?  line-buffered line-buffered

$stdout.sync = true
$stderr.sync = true

puts $stdout.tty?
puts $stderr.tty?

$stdout.puts 'stdout a'
$stdout.puts 'stdout b'
$stderr.puts 'stderr a'
$stderr.puts 'stderr b'
