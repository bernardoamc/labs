# Challenge

Second flag from the problem `Encrypted Pastebin` in [Hacker 101 CTF](https://ctf.hacker101.com/ctf)

## Usage

```bash
cargo run -- <endpoint> <ciphertext>
```

Example:

```bash
cargo run -- 'https://4ae2a9e890544638ead220e789dabdf3.ctf.hacker101.com' '3Jn6wKuyS4p-!Gh1nyBOt8BmZoLs0Tcq8vkEv2fI33OKNZEVmjWVSTmzaXO9pP6Yh!7nnFkbDg4Lyf1dQLr8R2W6o5KJtS-BVjsgCEuAvKcxul7UqErmUGja33tXx8!Rskzfxdo9EFBPmN!wr!joGFA2ESisccPjWEPyjHcbj3Sg9LKeFC6kHzbygD83ESPThgTKMRI2QdTLg18zBKSR1A~~'
```

The ciphertext is the base64 encoded string we get from the server from the `post` query string after creating a pastebin.

## Problem

We need to compute the decrypted value of each block's ciphertext called `DEC(ciphertext)` and XOR it with the previous ciphertext block or the `IV` if it's the first block.

We have a padding oracle attack in our hands since the server errors out when the padding is invalid.

## Padding oracle attack

See: https://bernardoamc.com/cbc-padding-oracle/
