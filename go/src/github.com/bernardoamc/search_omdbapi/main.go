package main

import (
	"flag"
	"fmt"
	"github.com/bernardoamc/omdbapi"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"strings"
)

var search = flag.String("s", "", "search query")
var movieType = flag.String("type", "", "type")
var year = flag.String("y", "", "year")
var download = flag.Bool("d", false, "download")

func main() {
	flag.Parse()

	options := make([]string, 0, 4)

	if *search != "" {
		options = appendOption(options, "s", *search)
	} else {
		fmt.Println("Search query must be provided...")
		os.Exit(1)
	}

	options = appendOption(options, "type", *movieType)
	options = appendOption(options, "y", *year)
	options = appendOption(options, "r", "json")

	result, err := omdbapi.Search(options)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("%d result(s) found!\n\n", result.TotalResults)

	for _, m := range result.Search {
		fmt.Printf("%s %s (%s)\nPoster: %s\n", m.Year, m.Title, m.Type, m.Poster)

		if *download {
			downloadPoster(m.Title, m.Poster)
		}
	}
}

func appendOption(options []string, option string, value string) []string {
	if value != "" {
		options = append(options, option+"="+url.QueryEscape(value))
	}

	return options
}

func downloadPoster(name string, url string) {
	if url != "N/A" {
		name = strings.ToLower(strings.Replace(name, " ", "_", -1))
		out, err := os.Create(name + ".jpg")
		defer out.Close()

		if err != nil {
			log.Fatal(err)
		}

		resp, err := http.Get(url)
		defer resp.Body.Close()

		if err != nil {
			log.Fatal(err)
		}

		_, err = io.Copy(out, resp.Body)

		if err != nil {
			log.Fatal(err)
		}
	}
}
