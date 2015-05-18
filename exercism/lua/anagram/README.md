# Anagram

Write a program that, given a word and a list of possible anagrams, selects the correct sublist.

Given `"listen"` and a list of candidates like `"enlists" "google"
"inlets" "banana"` the program should return a list containing
`"inlets"`.

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

Inspired by the Extreme Startup game [view source](https://github.com/rchatley/extreme_startup)
