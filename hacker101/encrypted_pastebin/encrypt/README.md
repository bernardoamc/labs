# Challenge

Third flag from the problem `Encrypted Pastebin` in [Hacker 101 CTF](https://ctf.hacker101.com/ctf)

## Usage

```bash
cargo run -- <endpoint> <payload>
```

Example:

```bash
cargo run -- "https://4ae2a9e890544638ead220e789dabdf3.ctf.hacker101.com" '{ "id": "3" }'
```

## Problem

We need to create a ciphertext that once decrypted, will contain a JSON in a format we control.

In the previous flags we know the JSON has format: `{ "id": "3", "key": "ACs-P08pemhM7jgi1quTmg~~" }`

## Details

Sending a random base64 encoded ciphertext to the server is enough for us to understand that the server complains about an invalid padding. This means that we have again a padding oracle attack in our hands.

The strategy is different from the previous challenge though. In the previous challenge we wanted to infer the value of `DEC(CIPHERTEXT)` given a ciphertext generated by the server.

In this challenge we want to create a `ciphertext` that we own and that will be decrypted to a value of our choice.

## Algorithm

The algorithm is interesting, since CBC decryption happens in a chain of blocks we need to start controlling the chain from the end to the beginning.

### Setup stage

1. Specify a JSON of our choice, for example: `"{ "id": "2" }"`
2. Split this JSON into blocks of 16 bytes each
3. Pad the last block to 16 bytes using the PKCS#7 algorithm
4. Generate a random block of 16 bytes
5. Set this random block to a variable called `last_block`

By the end of the setup you will have something like this:

```
plaintext = [ block_1, block_2, ..., block_n ] where `block_n` is padded
last_block = random_block
```

### Main stage

This is the fun part of the algorithm. We need to generate a ciphertext that when XORed with the decrypted value of `last_block`
will result in a value of our choice. Once we have this ciphertext we have to repeat the process until we can generate enough
ciphertext blocks to contain our entire JSON.

Let's see how this works on `iteration 1`:

1. Generate a new block of 16 bytes containg zeroes
2. Start enumerating the last byte of this block until we can generate a value that when XORed with the decrypted value of `last_block` provides us with a valid padding of `1`
3. XOR this last byte with the value `1`, this will give us a byte value that when XORed with the decrypted value of `last_block` will result in the last byte being `0`
4. Now we are ready to find the second last byte:
    1. Set the last byte of the new block to a value that results in `2` when decrypted
    2. Enumerate the second last byte of the new block until we can generate a value that when XORed with the decrypted value of `last_block` provides us with a valid padding of `2`
    3. XOR this byte with the value `2`, this will give us a byte that when XORed with the decrypted value of `last_block` will result in the second last byte being `0`
5. Repeat step 4 until we figure out a ciphertext that when XORed with the decrypted value of `last_block` will result in a block containing **all the bytes** being zero
6. XOR this block with the value of the last block from our plaintext created in the setup phase
7. Now we have a ciphertext block that when XORed with the decrypted value of `last_block` will result in a block containing the all bytes we want from the plaintext
8. Set this ciphertext block as the `last_block` and go back to step 1

## Interesting observations

When we pass an `id` that exists we get the title of the post, but fail to get the body since we don't have the proper key:

```
^FLAG^...$FLAG$
Attempting to decrypt page with title: <title>
Traceback (most recent call last):
  File "./main.py", line 74, in index
    body = decryptPayload(post['key'], body)
KeyError: 'key'
```

When we pass an `id` containing a single quotes we get an SQL error, which implies that we can perform SQL injection:

```
^FLAG^...$FLAG$
Traceback (most recent call last):
  File "./main.py", line 71, in index
    if cur.execute('SELECT title, body FROM posts WHERE id=%s' % post['id']) == 0:
  File "/usr/local/lib/python2.7/site-packages/MySQLdb/cursors.py", line 255, in execute
    self.errorhandler(self, exc, value)
  File "/usr/local/lib/python2.7/site-packages/MySQLdb/connections.py", line 50, in defaulterrorhandler
    raise errorvalue
ProgrammingError: (1064, "You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near ''' at line 1")
````

Following up on the observation above we can start enumerating the database tables by setting an id with:

- `"NULL UNION SELECT GROUP_CONCAT(table_name) AS title, NULL AS body FROM information_schema.tables WHERE table_schema=database()"`

Or even read columns a particular table:

- `"NULL UNION SELECT GROUP_CONCAT(column_name) as title, NULL as body FROM information_schema.columns WHERE table_name='tracking'"`

And last but not least, read content from a table:

- `"NULL UNION SELECT GROUP_CONCAT(headers) AS title, '' AS body FROM tracking"`
