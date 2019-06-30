# Script to check if base64 encoding can generate null bytes.

require 'base64'

puts "foo".unpack("B*")
puts Base64.urlsafe_encode64('foo', padding: false)
