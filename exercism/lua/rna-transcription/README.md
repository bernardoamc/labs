# Rna Transcription

Write a program that, given a DNA strand, returns its RNA complement (per RNA transcription).

Both DNA and RNA strands are a sequence of nucleotides.

The four nucleotides found in DNA are adenine (**A**), cytosine (**C**),
guanine (**G**) and thymidine (**T**).

The four nucleotides found in RNA are adenine (**A**), cytosine (**C**),
guanine (**G**) and uracil (**U**).

Given a DNA strand, its transcribed RNA strand is formed by replacing
each nucleotide with its complement:

* `G` -> `C`
* `C` -> `G`
* `T` -> `A`
* `A` -> `U`

### Getting started
First install lua using [homebrew][1]

    $ brew install lua

Then install [luarocks][2] to install packages for lua

    $ brew install luarocks

Then install [busted][3] testing framework for lua

    $ luarocks install busted
    
Then run your test

    $ busted bob_test.lua 
    
Other resources

  1. [Lua Style Guide][4]
  2. [Learn Lua in 15 minutes][5] 

[1]: http://brew.sh/
[2]: http://luarocks.org/
[3]: http://olivinelabs.com/busted/
[4]: https://github.com/Olivine-Labs/lua-style-guide
[5]: http://tylerneylon.com/a/learn-lua/

## Source

Rosalind [view source](http://rosalind.info/problems/rna)
