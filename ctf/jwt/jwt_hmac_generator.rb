require 'openssl'
require 'base64'
require 'json'

HMAC_SECRET = <<~DESC
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqi8TnuQBGXOGx/Lfn4JF
NYOH2V1qemfs83stWc1ZBQFCQAZmUr/sgbPypYzy229pFl6bGeqpiRHrSufHug7c
1LCyalyUEP+OzeqbEhSSuUss/XyfzybIusbqIDEQJ+Yex3CdgwC/hAF3xptV/2t+
H6y0Gdh1weVKRM8+QaeWUxMGOgzJYAlUcRAP5dRkEOUtSKHBFOFhEwNBXrfLd76f
ZXPNgyN0TzNLQjPQOy/tJ/VFq8CQGE4/K5ElRSDlj4kswxonWXYAUVxnqRN1LGHw
2G5QRE2D13sKHCC8ZrZXJzj67Hrq5h2SADKzVzhA8AW3WZlPLrlFT3t1+iZ6m+aF
KwIDAQAB
-----END PUBLIC KEY-----
DESC

def encode(hash_content)
  Base64.encode64(
    JSON.generate(hash_content)
  ).tr('+/', '-_').gsub(/[\n=]/, '')
end

def encode_signature(message)
  digest = OpenSSL::Digest.new('sha256')
  signature = OpenSSL::HMAC.digest(digest, HMAC_SECRET, message)
  Base64.encode64(signature).tr('+/', '-_').gsub(/[\n=]/, '')
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
  { typ: 'JWT', alg: 'HS256'},
  { iss: "Paradox", iat: 1592187870, exp: 1592187990, data: { pingu: "noots" } }
)
