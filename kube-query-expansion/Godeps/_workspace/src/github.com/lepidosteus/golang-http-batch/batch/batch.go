package batch

import (
	"fmt"
	"net/http"
	"io/ioutil"
	"bytes"
	"mime/multipart"
	"io"
	base64 "encoding/base64"
	"net/textproto"
)

const concurrentDefault = 10

type Callback func(url string, method string, payload string, vengine string, body string, data CallbackData, err error)

type CallbackData map[string]interface{}

var part1, part2, contentType, ocrImg string

type entry struct {
	url string
	method string
	jsonPayload string
    vengine string
	callback Callback
	data CallbackData
}

type batch struct {
	maxConcurrent int
	pool []*entry
}

func (b *batch) SetMaxConcurrent(maxConcurrent int) (previous int) {
	previous = b.maxConcurrent
	b.maxConcurrent = maxConcurrent
	return
}

func (b *batch) MaxConcurrent() (maxConcurrent int) {
	maxConcurrent = b.maxConcurrent
	return
}

func (b *batch) AddEntry(url string, method string, jsonPayload string, vengine string, callback Callback) {
	b.pool = append(b.pool, &entry{url, method, jsonPayload, vengine, callback, CallbackData{}})
	return
}

func (b *batch) AddEntryWithData(url string, method string, jsonPayload string, vengine string, callback Callback, data CallbackData) {
	b.pool = append(b.pool, &entry{url, method, jsonPayload, vengine, callback, data})
	return
}

func New() (*batch) {
	return &batch{concurrentDefault, []*entry{}}
}

func (b *batch) Clear() {
	b.pool = b.pool[0:0]
}

func (b *batch) Run() {
	// create and fill our working queue
	queue := make(chan *entry, len(b.pool))
	for _, entry := range b.pool {
		queue <- entry
	}
	close(queue)
	var total_threads int
	if b.maxConcurrent <= len(b.pool) {
		total_threads = b.maxConcurrent
	} else {
		total_threads = len(b.pool)
	}
	waiters := make(chan bool, total_threads)
	var threads int
	for threads = 0; threads < total_threads; threads++ {
		go process(queue, waiters, threads)
	}
	for ; threads > 0; threads-- {
		<-waiters
	}
}


func (b *batch) RunMultiRelated() {
	// create and fill our working queue
	queue := make(chan *entry, len(b.pool))
	for _, entry := range b.pool {
		queue <- entry
	}
	close(queue)
	var total_threads int
	if b.maxConcurrent <= len(b.pool) {
		total_threads = b.maxConcurrent
	} else {
		total_threads = len(b.pool)
	}
	waiters := make(chan bool, total_threads)
	var threads int
	for threads = 0; threads < total_threads; threads++ {
		go processMultiRelated(queue, waiters, threads)
	}
	for ; threads > 0; threads-- {
		<-waiters
	}
}

func processMultiRelated(queue chan *entry, waiters chan bool, thread_num int) {
	for entry := range queue {
        fmt.Printf("Method: %s\n", entry.method)
        fmt.Printf("Endpoint: %s\n", entry.url)
        fmt.Printf("vengine: %s\n", entry.vengine)
        fmt.Printf("payLoaded: %s\n", entry.jsonPayload)
		body_buf := bytes.NewBufferString("")
		body_writer := multipart.NewWriter(body_buf)
		boundary := body_writer.Boundary()
		contentType := fmt.Sprintf("multipart/related; boundary=\"%q\"", boundary)
		fmt.Println(contentType)
		part1 := make(textproto.MIMEHeader)
		part1.Set("Content-Type", "application/json; charset=UTF-8")
		part1_writer, err := body_writer.CreatePart(part1)
		if err != nil {
			fmt.Println(err)
			//body_writer.Close()
			//continue
		}
	    var jsonStr = []byte(`{"engine":"tesseract", "preprocessors":["stroke-width-transform"], "preprocessor-args":{"stroke-width-transform":"1"}}
	    	`)
		_, err = part1_writer.Write(jsonStr)
		if err != nil {
			fmt.Println(err)
			//body_writer.Close()
			//continue
		}
	 	fmt.Sprintf("part1 %v", part1)
		part2 := make(textproto.MIMEHeader)
		part2_writer, err := body_writer.CreatePart(part2)
		if err != nil {
			fmt.Println(err)
			//body_writer.Close()
			//continue
		}
		part2.Set("Content-Type", "Content-Type; image/jpeg")
		part2.Set("Content-Type", "Content-Disposition: attachment; filename=image.jpg")
	 	fmt.Println("part2 %s", part2)
		payLoad, err := base64.StdEncoding.DecodeString(entry.jsonPayload)
		_, err = io.Copy(part2_writer, bytes.NewBuffer(payLoad[:]))
		if err != nil {
			fmt.Println(err)
			//body_writer.Close()
			//continue
		}
		fmt.Sprintf("apiForm: %s", entry.url)
		fmt.Sprintf("multipart/related; boundary=%q", boundary)
		fmt.Println("%s", body_buf)
		req, err := http.NewRequest(entry.method, entry.url, body_buf)
        if err != nil {
	    	//fmt.Println("Error: %v\n", err)
	    	//continue
	    }
		req.Header.Set("Content-Type", contentType)
		client := &http.Client{}
		response, err := client.Do(req)
		if err != nil {
            entry.callback(entry.url, entry.method, entry.jsonPayload, entry.vengine, "", entry.data, err)
			continue
		}
		defer response.Body.Close()
		body_writer.Close()
		contents, err := ioutil.ReadAll(response.Body)
        if err != nil {
	    	fmt.Printf("Error: %v\n", err)
            entry.callback(entry.url, entry.method, entry.jsonPayload, entry.vengine, "", entry.data, err)
            continue
        }
		entry.callback(entry.url, entry.method, entry.jsonPayload, entry.vengine, string(contents), entry.data, nil)
	}
	waiters <- true
}

func process(queue chan *entry, waiters chan bool, thread_num int) {
	for entry := range queue {
        var payLoad = []byte(entry.jsonPayload)
		req, err := http.NewRequest(entry.method, entry.url, bytes.NewBuffer(payLoad))
		if err != nil {
			//fmt.Println(err)
			continue
		}
		req.Header.Set("Content-Type", "application/json")
		client := &http.Client{}
		response, err := client.Do(req)
		if err != nil {
            entry.callback(entry.url, entry.method, entry.jsonPayload, entry.vengine, "", entry.data, err)
			continue
		}
		defer response.Body.Close()
		contents, err := ioutil.ReadAll(response.Body)
        if err != nil {
            //fmt.Printf("Error: %v\n", err)
            entry.callback(entry.url, entry.method, entry.jsonPayload, entry.vengine, "", entry.data, err)
            continue
        }
		entry.callback(entry.url, entry.method, entry.jsonPayload, entry.vengine, string(contents), entry.data, nil)
	}
	waiters <- true
}
