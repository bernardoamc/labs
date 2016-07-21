package main

import (
	"crypto/sha256"
	"crypto/sha512"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
)

var digest = flag.String("d", "256", "digest type (256, 384, 512)")

func main() {
	flag.Parse()
	bytes, err := ioutil.ReadAll(os.Stdin)

	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}

	switch *digest {
	case "256":
		fmt.Printf("%x\n", sha256.Sum256(bytes))
	case "384":
		fmt.Printf("%x\n", sha512.Sum384(bytes))
	case "512":
		fmt.Printf("%x\n", sha512.Sum512(bytes))
	default:
		fmt.Println("Error, unrecognized digest format")
		os.Exit(1)
	}
}
