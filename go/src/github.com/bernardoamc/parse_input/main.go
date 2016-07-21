package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
)

var file = flag.String("f", "", "filename")

func main() {
	flag.Parse()

	if *file == "" {
		fmt.Println("Reading from stdin!")
		fmt.Println(readlines(os.Stdin))
	} else {
		f := openFile(*file)
		fmt.Println(readlines(f))
		f.Close()
	}
}

func openFile(filename string) *os.File {
	f, err := os.Open(filename)

	if err != nil {
		fmt.Printf("Error opening %s: %v", filename, err)
	}

	return f
}

func readlines(f *os.File) string {
	lines, separator := "", ""

	input := bufio.NewScanner(f)

	for input.Scan() {
		lines += separator + input.Text()
		separator = " - "
	}

	return lines
}
