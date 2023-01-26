package main

import (
	"fmt"
	"net/http"
)

func main() {
	h := http.FileServer(http.Dir("./_site"))
	http.ListenAndServe(":8088", h)
	fmt.Printf("Serving HTTP on 0.0.0.0 port 8088 ...\n")
}
