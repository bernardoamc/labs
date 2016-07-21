// Dup2 prints the count and text of lines that appear more than once
// in the input. It reads from a list of named files.

// This program reads the entire input into memory, split it into lines
// all at once, then process the lines.

package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strings"
)

func main() {
	counts := make(map[string]int)

	for _, filename := range os.Args[1:] {
		// Returns a byte slice that must be converted to string.
		data, err := ioutil.ReadFile(filename)

		if err != nil {
			fmt.Fprintf(os.Stderr, "dup2: %v\n", err)
			continue
		}

		fmt.Println("---", filename, "---")
		for _, line := range strings.Split(string(data), "\n") {
			counts[line]++
		}
	}

	for line, n := range counts {
		if n > 1 {
			fmt.Printf("%d\t%s\n", n, line)
		}
	}
}
