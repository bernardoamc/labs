package main

import (
	"fmt"
)

func main() {
	//!+array
	a := [...]int{0, 1, 2, 3, 4, 5}
	reverse_ptr(&a)
	fmt.Println(a) // "[5 4 3 2 1 0]"
	//!-array

	//!+slice
	s := []int{0, 1, 2, 3, 4, 5}
	// Rotate s left by two positions.
	reverse(s[:2])
	reverse(s[2:])
	reverse(s)
	fmt.Println(s) // "[2 3 4 5 0 1]"
	//!-slice

	k := []int{0, 1, 2, 3, 4, 5}
	rotate(k)
	fmt.Println(k) // "[2 3 4 5 0 1]"

	strs := []string{"foca", "alada", "foca", "k", "stamina"}
	fmt.Println(remove_duplicates(strs))
}

func reverse_ptr(s *[6]int) {
	for i, j := 0, len(s)-1; i < j; i, j = i+1, j-1 {
		s[i], s[j] = s[j], s[i]
	}
}

//!+rev
// reverse reverses a slice of ints in place.
func reverse(s []int) {
	for i, j := 0, len(s)-1; i < j; i, j = i+1, j-1 {
		s[i], s[j] = s[j], s[i]
	}
}

//!-rev

func rotate(s []int) {
	f := s[0]
	copy(s[0:], s[1:])
	s[len(s)-1] = f
}

func remove_duplicates(strings []string) []string {
	i := 0

	for _, s := range strings {
		if !contains(strings[:i], s) {
			strings[i] = s
			i++
		}
	}

	return strings[:i]
}

func contains(strings []string, str string) bool {
	for _, s := range strings {
		if s == str {
			return true
		}
	}

	return false
}
