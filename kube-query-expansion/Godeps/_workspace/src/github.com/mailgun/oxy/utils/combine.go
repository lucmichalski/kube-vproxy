package utils

import (
	"net/http"
	"encoding/json"
)

type ErrorCombineHandler interface {
	ServeHTTP(w http.ResponseWriter, req *http.Request, err error)
}

var DefaultCombineHandler ErrorCombineHandler = &CombineHandler{}

type CombineHandler struct {
}

func (e *CombineHandler) ServeHTTP(w http.ResponseWriter, req *http.Request, err error) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8") 
    myItems := []string{"item1", "item2", "item3"}
    a, _ := json.Marshal(myItems)
    w.Write(a)
}

type ErrorCombineHandlerFunc func(http.ResponseWriter, *http.Request, error)

// ServeHTTP calls f(w, r).
func (f ErrorCombineHandlerFunc) ServeHTTP(w http.ResponseWriter, r *http.Request, err error) {
	f(w, r, err)
}