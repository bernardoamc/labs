// command_line prints its command-line arguments.
package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	var s, sep string

	// Version 1
	for i := 1; i < len(os.Args); i++ {
		s += sep + os.Args[i]
		sep = " "
	}

	fmt.Println(s)

	// Version 2
	s, sep = "", ""

	for _, arg := range os.Args[1:] {
		s += sep + arg
		sep = " "
	}

	fmt.Println(s)

	// Version 3
	fmt.Println(strings.Join(os.Args[1:], " "))

	// Version 4 for debug
	fmt.Println(os.Args[1:])

	// If I want to print everything in the os.Args
	fmt.Println(strings.Join(os.Args, " "))

	// Remember that os.Args[:] is the same as os.Args[0:len(os.Args)]
	fmt.Println(strings.Join(os.Args[:], " "))

	// Printing with numbers:
	s = ""

	for index, arg := range os.Args[1:] {
		fmt.Println(index, "-", arg)
	}
}
