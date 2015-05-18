# Robot Name

Write a program that manages robot factory settings.

When robots come off the factory floor, they have no name.

The first time you boot them up, a random name is generated, such as
RX837 or BC811.

Every once in a while we need to reset a robot to its factory settings,
which means that their name gets wiped. The next time you ask, it gets a
new name.


## For bonus points

Did you get the tests passing and the code clean? If you want to, these
are some additional things you could try:

- Random names means a risk of collisions. Make sure the same name is
  never used twice. Feel free to introduce additional tests.

Then please share your thoughts in a comment on the submission. Did this
experiment make the code better? Worse? Did you learn anything from it?

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

A debugging session with Paul Blackwell at gSchool. [view source](http://gschool.it)
