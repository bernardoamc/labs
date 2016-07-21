package omdbapi

const OmdbApiURL = "http://www.omdbapi.com/"

type SearchResult struct {
	Search       []*Item
	TotalResults int `json:"total_results"`
}

type Item struct {
	Title  string
	Year   string
	Type   string
	Poster string
}
