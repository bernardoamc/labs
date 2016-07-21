package omdbapi

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
)

func Search(options []string) (*SearchResult, error) {
	opts := strings.Join(options, "&")
	resp, err := http.Get(OmdbApiURL + "?" + opts)
	defer resp.Body.Close()

	if err != nil {
		return nil, err
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("OmdbAPI search query failed: %s", resp.Status)
	}

	var result SearchResult
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}

	return &result, nil
}
