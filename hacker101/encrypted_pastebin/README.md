# Challenge

`Encrypted Pastebin` in [Hacker 101 CTF](https://ctf.hacker101.com/ctf)

## Flag 1

After submitting the form we notice that there is a `post` query string that identifies our pastebin. Playing around with the query string yields all sorts of information, including our first flag.

```
^FLAG^...$FLAG$
Traceback (most recent call last):
  File "./main.py", line 69, in index
    post = json.loads(decryptLink(postCt).decode('utf8'))
  File "./common.py", line 46, in decryptLink
    data = b64d(data)
  File "./common.py", line 11, in <lambda>
    b64d = lambda x: base64.decodestring(x.replace('~', '=').replace('!', '/').replace('-', '+'))
  File "/usr/local/lib/python2.7/base64.py", line 328, in decodestring
    return binascii.a2b_base64(s)
Error: Incorrect padding
```

and

```
^FLAG^...$FLAG$
Traceback (most recent call last):
  File "./main.py", line 69, in index
    post = json.loads(decryptLink(postCt).decode('utf8'))
  File "./common.py", line 49, in decryptLink
    return unpad(cipher.decrypt(data))
  File "/usr/local/lib/python2.7/site-packages/Crypto/Cipher/blockalgo.py", line 295, in decrypt
    return self._cipher.decrypt(ciphertext)
ValueError: Input strings must be a multiple of 16 in length
```

and

```
^FLAG^...$FLAG$
Traceback (most recent call last):
  File "./main.py", line 69, in index
    post = json.loads(decryptLink(postCt).decode('utf8'))
  File "./common.py", line 49, in decryptLink
    return unpad(cipher.decrypt(data))
  File "./common.py", line 22, in unpad
    raise PaddingException()
PaddingException
```

and

```
^FLAG^...$FLAG$
Traceback (most recent call last):
  File "./main.py", line 69, in index
    post = json.loads(decryptLink(postCt).decode('utf8'))
  File "./common.py", line 48, in decryptLink
    cipher = AES.new(staticKey, AES.MODE_CBC, iv)
  File "/usr/local/lib/python2.7/site-packages/Crypto/Cipher/AES.py", line 95, in new
    return AESCipher(key, *args, **kwargs)
  File "/usr/local/lib/python2.7/site-packages/Crypto/Cipher/AES.py", line 59, in __init__
    blockalgo.BlockAlgo.__init__(self, _AES, key, *args, **kwargs)
  File "/usr/local/lib/python2.7/site-packages/Crypto/Cipher/blockalgo.py", line 141, in __init__
    self._cipher = factory.new(key, *args, **kwargs)
ValueError: IV must be 16 bytes long
```

besides getting our first flag we also learn important information about the system.

1. The block size is `16`
2. The first 16 bytes of the `post` corresponds to the `IV`
3. We have a padding oracle (the system kindly tells us when our padding is wrong)
4. We know that the code replace certain characters before base64 decoding

## Flag 2

See the `decrypt` folder to decrypt the ciphertext in the `post` query string.

## Flag 3

See the `encrypt` folder to generate our own ciphertexts to be passed in the `post` query string.

## Flag 4

Still uses the `encrypt` folder and relies on SQL injection to find a certain piece of information.
