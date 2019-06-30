require 'socket'
require 'openssl'

socket = TCPSocket.new('localhost',  443)
ssl_context = OpenSSL::SSL::SSLContext.new
ssl_context.ca_file = '/usr/local/etc/openssl/cert.pem'
ssl_context.verify_mode =  OpenSSL::SSL::VERIFY_PEER
socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
socket.connect
socket.write("TEST")
