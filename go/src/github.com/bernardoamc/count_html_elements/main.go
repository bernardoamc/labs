package main

import (
	"fmt"
	"os"

	"golang.org/x/net/html"
)

func main() {
	elementsCount := make(map[string]int)

	doc, err := html.Parse(os.Stdin)

	if err != nil {
		fmt.Fprintf(os.Stderr, "countHTMLElements: %v\n", err)
		os.Exit(1)
	}

	countElements(doc, elementsCount)

	for key, value := range elementsCount {
		fmt.Printf("%s: %d\n", key, value)
	}
}

func countElements(doc *html.Node, elementsCount map[string]int) {
	if doc.Type == html.ElementNode {
		elementsCount[doc.Data]++
	}

	for el := doc.FirstChild; el != nil; el = el.NextSibling {
		countElements(el, elementsCount)
	}
}
