package main

import (
	"fmt"
	"os"

	"golang.org/x/net/html"
)

var depth int

func main() {
	doc, err := html.Parse(os.Stdin)

	if err != nil {
		fmt.Fprintf(os.Stderr, "TraverseHTMLElements: %v\n", err)
		os.Exit(1)
	}

	// Testing anonymous functions
	pre := func(node *html.Node) {
		if node.Type == html.ElementNode {
			fmt.Printf("%*s<%s>\n", depth*2, "", node.Data)
			depth++
		}
	}

	// Testing anonymous functions
	pos := func(node *html.Node) {
		if node.Type == html.ElementNode {
			depth--
			fmt.Printf("%*s</%s>\n", depth*2, "", node.Data)
		}
	}

	traverseElements(doc, pre, pos)
}

func traverseElements(node *html.Node, pre, pos func(*html.Node)) {
	pre(node)

	for el := node.FirstChild; el != nil; el = el.NextSibling {
		traverseElements(el, pre, pos)
	}

	pos(node)
}
