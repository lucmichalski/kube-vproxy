package batchrelated

import (
	"fmt"
	"net/http"
	"io/ioutil"
	"bytes"
	"mime/multipart"
	"io"
	"image"
	"image/jpeg"
	"net/textproto"
)

const concurrentDefaultRelated = 10

type CallbackRelated func(form string, method string, ocrengine string, parameters string, srcImg image.Image, res string, dataRelated CallbackDataRelated, err error)

type CallbackRelatedData map[string]interface{}

type endpoint struct {
	form string
	method string
    ocrengine string
	parameters string
	srcImg image.Image
	callbackRelated CallbackRelated
	dataRelated CallbackDataRelated
}

var part1, part2, contentType, ocrImg string

type batchrelated struct {
	maxConcurrentRelated int
	pool []*endpoint
}

func (bmr *batchrelated) SetMaxConcurrentRelated(maxConcurrentRelated int) (previous int) {
	previous = bmr.maxConcurrentRelated
	bmr.maxConcurrentRelated = maxConcurrentRelated
	return
}

func (bmr *batchrelated) MaxConcurrentRelated() (maxConcurrentRelated int) {
	maxConcurrentRelated = bmr.maxConcurrentRelated
	return
}

func (bmr *batchrelated) AddEndpoint(form string, method string, ocrengine string, parameters string, srcImg image.Image, callbackRelated CallbackRelated) {
	bmr.pool = append(bmr.pool, &endpoint{form, method, ocrengine, parameters, srcImg, callbackRelated, CallbackDataRelated{}})
	return
}

func (bmr *batchrelated) AddEndpointWithData(form string, method string, ocrengine string, parameters string, srcImg image.Image, callbackRelated CallbackRelated, dataRelated CallbackRelatedData) {
	bmr.pool = append(bmr.pool, &endpoint{form, method, ocrengine, parameters, srcImg, callbackRelated, dataRelated})
	return
}

func New() (*batchrelated) {
	return &batchrelated{concurrentDefaultRelated, []*endpoint{}}
}

func (bmr *batchrelated) Clear() {
	bmr.pool = bmr.pool[0:0]
}

func (bmr *batchrelated) Run() {
	// create and fill our working queue
	queue := make(chan *endpoint, len(bmr.pool))
	for _, endpoint := range bmr.pool {
		queue <- endpoint
	}
	close(queue)
	var total_threads int
	if bmr.maxConcurrent <= len(bmr.pool) {
		total_threads = bmr.maxConcurrentRelated
	} else {
		total_threads = len(bmr.pool)
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

func proces(queue chan *endpoint, waiters chan bool, thread_num int) {
	for endpoint := range queue {

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
			body_writer.Close()
			return
		}

	    var jsonStr = []byte(`{"engine":"tesseract", "preprocessors":["stroke-width-transform"], "preprocessor-args":{"stroke-width-transform":"1"}}
	    	`)

		_, err = part1_writer.Write(jsonStr)
	 	fmt.Sprintf("part1 %v", part1)

		part2 := make(textproto.MIMEHeader)
		part2_writer, err := body_writer.CreatePart(part2)
		part2.Set("Content-Type", "Content-Type; image/jpeg")
		part2.Set("Content-Type", "Content-Disposition: attachment; filename=image.jpg")
		if err != nil {
			fmt.Println(err)
			body_writer.Close()
			return
		}

	 	fmt.Println("part2 %s", part2)
		//fmt.Sprintf("Format: %s", formatName)

		buf := bytes.NewBuffer(nil)
		if err := jpeg.Encode(buf, endpoint.srcImg, nil); err != nil {
			fmt.Println(err)
			body_writer.Close()
			return
		}

		ocrImg = fmt.Sprintf("%s", buf.String(), boundary)
		io.Copy(part2_writer, bytes.NewBufferString(ocrImg))
		if err != nil {
			fmt.Println(err)
			body_writer.Close()
			return
		}

		fmt.Sprintf("apiForm: %s", endpoint.form)
		fmt.Sprintf("multipart/related; boundary=%q", boundary)

		body_writer.Close()

		fmt.Println("%s", body_buf)

		/*
		req, err := http.NewRequest("POST", endpoint.url, ioutil.NopCloser(body_buf))
		req.Header.Set("Content-Type", contentType)

		multipart, err := req.MultipartReader()
		if multipart == nil {
			fmt.Sprintf("expected multipart; error: %v", err)
		}

	    for {
	        part, err := multipart.NextPart()
	        fmt.Printf("Part %s\n", part)
	        if err == io.EOF {
	            break
	        }
	        if part.FileName() == "" {
	            continue
	        }
			contents, err := multipart.ReadForm(200000)
	        defer part.Close()
			fmt.Printf("Output %s\n", contents)
	    }
		*/

		req, err := http.NewRequest(endpoint.method, endpoint.form, ioutil.NopCloser(body_buf))
		req.Header.Set("Content-Type", contentType)
//		log.Printf(req)
		client := &http.Client{}
		response, err := client.Do(req)
        if err != nil {
	    fmt.Printf("Error: %v\n", err)
            endpoint.callbackRelated(endpoint.form, endpoint.method, endpoint.ocrengine, endpoint.parameters, endpoint.srcImg, "", endpoint.dataRelated, err)
            continue
        }
		defer response.Body.Close()
		contents, err := ioutil.ReadAll(response.Body)
        if err != nil {
            fmt.Printf("Error: %v\n", err)
                endpoint.callbackRelated(endpoint.form, endpoint.method, endpoint.ocrengine, endpoint.parameters, endpoint.srcImg, "", endpoint.dataRelated, err)
                continue
        }
		endpoint.callbackRelated(endpoint.form, endpoint.method, endpoint.ocrengine, endpoint.parameters, endpoint.srcImg, string(contents), endpoint.dataRelated, nil)

	}
	waiters <- true
}
