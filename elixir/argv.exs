IO.inspect System.argv
IO.inspect OptionParser.parse(System.argv, switches: [ help: :boolean], aliases:  [ h: :help ])
