package main // import "hello"

import (
	"encoding/json"
	"flag"
	"log"
	"net/http"
	"runtime"
)

type Message struct {
	Message string `json:"message"`
}

const helloWorldString = "Hello, World!"

var debug = flag.Bool("debug", false, "debug logging")

func main() {
	flag.Parse()
	runtime.GOMAXPROCS(runtime.NumCPU())

	http.HandleFunc("/json", jsonHandler)
	http.ListenAndServe(":9080", Log(http.DefaultServeMux))
}

func Log(handler http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if *debug == true {
			log.Printf("%s %s %s", r.RemoteAddr, r.Method, r.URL)
		}
		handler.ServeHTTP(w, r)
	})
}

func jsonHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(&Message{helloWorldString})
}
