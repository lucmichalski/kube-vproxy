package batch

import (
	"fmt"
	"net/http"
	"io/ioutil"
	"bytes"
	"mime/multipart"
	"io"
	"encoding/json"
	"log"
	base64 "encoding/base64"
	"net/textproto"
)

const concurrentDefault = 10

type Callback func(url string, method string, vengine string, payload string, body string, data CallbackData, err error)

type CallbackData map[string]interface{}

var part1, part2, contentType, ocrImg, imagePrefix, endPayload string

type entry struct {
	url string
	method string
    vengine string
	payload string
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

func (b *batch) AddEntry(url string, method string, vengine string, payload string, callback Callback) {
	b.pool = append(b.pool, &entry{url, method, vengine, payload, callback, CallbackData{}})
	return
}

func (b *batch) AddEntryWithData(url string, method string, vengine string, payload string, callback Callback, data CallbackData) {
	b.pool = append(b.pool, &entry{url, method, vengine, payload, callback, data})
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

type OcrRequest struct {
	EngineType        string          		 `json:"engine"`
	PreprocessorArgs  map[string]interface{} `json:"preprocessor-args"`
	InplaceDecode 	  bool 					 `json:"inplace_decode"`
}

func process(queue chan *entry, waiters chan bool, thread_num int) {
	for entry := range queue {
		if entry.vengine == "tessaract" {

			body := &bytes.Buffer{}
			writer := multipart.NewWriter(body)

			// will add dynamic parameters later and rotation
		    jsonBytes := []byte(`{"engine":"tesseract", "preprocessor-args":{"stroke-width-transform":"0"}, "inplace_decode": false}`)
			ocrRequest := OcrRequest{} 
			err := json.Unmarshal(jsonBytes, &ocrRequest)
			if err != nil {
				log.Println("Unable to unmarshall OCR Engine parameters")
	            entry.callback(entry.url, entry.method, entry.vengine, entry.payload, "", entry.data, err)
				continue
		    }

			mimeHeader := textproto.MIMEHeader{}
			mimeHeader.Set("Content-Type", "application/json")
			part, err := writer.CreatePart(mimeHeader)
			if err != nil {
				err = writer.Close()
	            entry.callback(entry.url, entry.method, entry.vengine, entry.payload, "", entry.data, err)
				continue
			}
			_, err = part.Write(jsonBytes)
			if err != nil {
				err = writer.Close()
	            entry.callback(entry.url, entry.method, entry.vengine, entry.payload, "", entry.data, err)
				continue
			}

			partHeaders := textproto.MIMEHeader{}
			partHeaders.Set("Content-Type", "image/jpeg")
			partHeaders.Set("Content-Disposition", "attachment; filename=\"attachment.txt\".")
			partAttach, err := writer.CreatePart(partHeaders)
			if err != nil {
				err = writer.Close()
	            entry.callback(entry.url, entry.method, entry.vengine, entry.payload, "", entry.data, err)
				continue
			}
		    dec := base64.NewDecoder(base64.StdEncoding, bytes.NewBuffer([]byte(entry.payload)))
			_, err = io.Copy(partAttach, dec)
			if err != nil {
				err = writer.Close()
	            entry.callback(entry.url, entry.method, entry.vengine, entry.payload, "", entry.data, err)
				continue
			}
			if err != nil {
				err = writer.Close()
	            entry.callback(entry.url, entry.method, entry.vengine, entry.payload, "", entry.data, err)
				continue
			}
			err = writer.Close()
			// create a client
			client := &http.Client{}
			// Add it to the configuration file
			req, err := http.NewRequest("POST", "http://192.168.99.100:9292/ocr-file-upload", bytes.NewReader(body.Bytes()))
			// set content type
			contentType := fmt.Sprintf("multipart/related; boundary=%q", writer.Boundary())
			req.Header.Set("Content-Type", contentType)
			// send POST request
			response, err := client.Do(req)
			if err != nil {
	            entry.callback(entry.url, entry.method, entry.vengine, entry.payload, "", entry.data, err)
				continue
			}
			if response.StatusCode >= 400 {
				defer response.Body.Close()
	            entry.callback(entry.url, entry.method, entry.vengine, entry.payload, "", entry.data, err)
				continue
			}
			contents, err := ioutil.ReadAll(response.Body)
			if err != nil {
				defer response.Body.Close()
	            entry.callback(entry.url, entry.method, entry.vengine, entry.payload, "", entry.data, err)
				continue
			} else {
		        //log.Println("%s", contents)
		        log.Println("------- New multi-part related query - END -------")
				defer response.Body.Close()
				entry.callback(entry.url, entry.method, entry.vengine, entry.payload, string(contents), entry.data, nil)			
			}

		} else if entry.vengine !="" {

		    //log.Println("------- New VMX - JSON Payload query - START -------")
		    //log.Println("Method Used: ", entry.method)
		    //log.Println("Endpoint URL: ", entry.url)
		    //log.Println("Visual Engine Type to query: ", entry.vengine)
			request, err := http.NewRequest(entry.method, entry.url, bytes.NewBufferString(entry.payload))
		    if err != nil {
	            entry.callback(entry.url, entry.method, entry.vengine, entry.payload, "", entry.data, err)
				continue
		    }
			request.Header.Set("Content-Type", "application/json")
			client := &http.Client{}
			response, err := client.Do(request)
			if err != nil {
				log.Println("Error sending POST request")
	            entry.callback(entry.url, entry.method, entry.vengine, entry.payload, "", entry.data, err)
				continue
			}
			contents, err := ioutil.ReadAll(response.Body)
			if err != nil {
				//log.Println("Error reading response")
				defer response.Body.Close()
	            entry.callback(entry.url, entry.method, entry.vengine, entry.payload, "", entry.data, err)
				continue
			} else {
		        //log.Printf("%s", contents)
		        //log.Println("------- New multi-part related query - END -------")
				defer response.Body.Close()
				entry.callback(entry.url, entry.method, entry.vengine, entry.payload, string(contents), entry.data, nil)			
			}	

		} else {
			continue
		}

	}
	waiters <- true
}
