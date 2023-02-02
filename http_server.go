package main

import (
	"fmt"
	"net/http"
	"strings"
)

type dirWithFallback struct {
	http.Dir
}

var _ http.FileSystem = (*dirWithFallback)(nil)

func (d *dirWithFallback) Open(name string) (http.File, error) {
	if strings.HasSuffix(name, ".md") {
		f, err := d.Dir.Open(name[:len(name)-3] + ".html")
		if err == nil {
			return f, nil
		}
	}

	f, err := d.Dir.Open(name)
	if err != nil {
		f, err := d.Dir.Open(name + ".html")
		if err != nil {
			return nil, err
		}
		return f, nil
	}
	return f, nil
}

func main() {
	h := http.FileServer(&dirWithFallback{http.Dir("./_site")})
	http.ListenAndServe(":8088", h)
	fmt.Printf("Serving HTTP on 0.0.0.0 port 8088 ...\n")
}
