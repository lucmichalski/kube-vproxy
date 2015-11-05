package blipparutils

import (
	"net/http"
	"encoding/json"
)

var BlipparDefaultHandler = &BlipparHandler{}

type BlipparHandler struct {
}

func (e *BlipparHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8") 
    myItems := []string{"item1", "item2", "item3"}
    a, _ := json.Marshal(myItems)
    w.Write(a)
}