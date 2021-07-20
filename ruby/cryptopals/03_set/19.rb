require_relative '../helpers'
require 'openssl'

NONCE = 0
KEY = 16.times.map { rand(0..255) }

CIPHERTEXTS = [
  'SSBoYXZlIG1ldCB0aGVtIGF0IGNsb3NlIG9mIGRheQ==',
  'Q29taW5nIHdpdGggdml2aWQgZmFjZXM=',
  'RnJvbSBjb3VudGVyIG9yIGRlc2sgYW1vbmcgZ3JleQ==',
  'RWlnaHRlZW50aC1jZW50dXJ5IGhvdXNlcy4=',
  'SSBoYXZlIHBhc3NlZCB3aXRoIGEgbm9kIG9mIHRoZSBoZWFk',
  'T3IgcG9saXRlIG1lYW5pbmdsZXNzIHdvcmRzLA==',
  'T3IgaGF2ZSBsaW5nZXJlZCBhd2hpbGUgYW5kIHNhaWQ=',
  'UG9saXRlIG1lYW5pbmdsZXNzIHdvcmRzLA==',
  'QW5kIHRob3VnaHQgYmVmb3JlIEkgaGFkIGRvbmU=',
  'T2YgYSBtb2NraW5nIHRhbGUgb3IgYSBnaWJl',
  'VG8gcGxlYXNlIGEgY29tcGFuaW9u',
  'QXJvdW5kIHRoZSBmaXJlIGF0IHRoZSBjbHViLA==',
  'QmVpbmcgY2VydGFpbiB0aGF0IHRoZXkgYW5kIEk=',
  'QnV0IGxpdmVkIHdoZXJlIG1vdGxleSBpcyB3b3JuOg==',
  'QWxsIGNoYW5nZWQsIGNoYW5nZWQgdXR0ZXJseTo=',
  'QSB0ZXJyaWJsZSBiZWF1dHkgaXMgYm9ybi4=',
  'VGhhdCB3b21hbidzIGRheXMgd2VyZSBzcGVudA==',
  'SW4gaWdub3JhbnQgZ29vZCB3aWxsLA==',
  'SGVyIG5pZ2h0cyBpbiBhcmd1bWVudA==',
  'VW50aWwgaGVyIHZvaWNlIGdyZXcgc2hyaWxsLg==',
  'V2hhdCB2b2ljZSBtb3JlIHN3ZWV0IHRoYW4gaGVycw==',
  'V2hlbiB5b3VuZyBhbmQgYmVhdXRpZnVsLA==',
  'U2hlIHJvZGUgdG8gaGFycmllcnM/',
  'VGhpcyBtYW4gaGFkIGtlcHQgYSBzY2hvb2w=',
  'QW5kIHJvZGUgb3VyIHdpbmdlZCBob3JzZS4=',
  'VGhpcyBvdGhlciBoaXMgaGVscGVyIGFuZCBmcmllbmQ=',
  'V2FzIGNvbWluZyBpbnRvIGhpcyBmb3JjZTs=',
  'SGUgbWlnaHQgaGF2ZSB3b24gZmFtZSBpbiB0aGUgZW5kLA==',
  'U28gc2Vuc2l0aXZlIGhpcyBuYXR1cmUgc2VlbWVkLA==',
  'U28gZGFyaW5nIGFuZCBzd2VldCBoaXMgdGhvdWdodC4=',
  'VGhpcyBvdGhlciBtYW4gSSBoYWQgZHJlYW1lZA==',
  'QSBkcnVua2VuLCB2YWluLWdsb3Jpb3VzIGxvdXQu',
  'SGUgaGFkIGRvbmUgbW9zdCBiaXR0ZXIgd3Jvbmc=',
  'VG8gc29tZSB3aG8gYXJlIG5lYXIgbXkgaGVhcnQs',
  'WWV0IEkgbnVtYmVyIGhpbSBpbiB0aGUgc29uZzs=',
  'SGUsIHRvbywgaGFzIHJlc2lnbmVkIGhpcyBwYXJ0',
  'SW4gdGhlIGNhc3VhbCBjb21lZHk7',
  'SGUsIHRvbywgaGFzIGJlZW4gY2hhbmdlZCBpbiBoaXMgdHVybiw=',
  'VHJhbnNmb3JtZWQgdXR0ZXJseTo=',
  'QSB0ZXJyaWJsZSBiZWF1dHkgaXMgYm9ybi4=',
].map { |c| aes_ctr_encrypt(base64_decode(c), KEY, NONCE) }

=begin
  Since every plaintext got encrypted with the same keystream
  this seems to be breakable using the repeating-XOR attack.
  Remember this attack from our challenge 6?

  But how? What's the intuition behind it?

  1. Suppose each KEYSTREAM is 16 bytes
  2. The first 16 bytes of every message is always encrypted with this keystream.
  3. The next 16 bytes of every message is always encrypted with the next keystream.
  4. And so on and so forth.

  So we need to:

  1. Concatenate the first 16 bytes of every message, and apply repeating XOR
  2. Concated the next 16 bytes of every message, and apply repeating XOR
  3. Until we exhaust the entire message.

  But not every message has the same length:

  1. That's ok, we use the message with the smallest length and apply our attack.
  2. We might miss something, but at leas we will decrypted the majority
     of our messages.
=end

MAX_INPUT = CIPHERTEXTS.max_by(&:length)
MAX_INPUT_SIZE = MAX_INPUT.size
MIN_INPUT = CIPHERTEXTS.min_by(&:length)
MIN_INPUT_SIZE = MIN_INPUT.size

padded_ciphertexts = CIPHERTEXTS.map do |c|
  c[0...MIN_INPUT_SIZE]
end

keystream = padded_ciphertexts.transpose.map do |transposed_block|
  max_score = 0
  chosen_character = ''

  (0..255).each do |xored_candidate|
    xor_result = xor_bytes_against_byte(
      transposed_block.compact,
      xored_candidate
    ).pack('C*')

    score = english_score(xor_result)

    if score > max_score
      max_score = score
      chosen_character = xored_candidate
    end
  end

  chosen_character
end.pack('C*')

puts "Potential keystream: #{keystream}"

padded_ciphertexts.each do |c|
  puts xor_bytes_repeating(c, keystream.bytes).pack('C*')
end
