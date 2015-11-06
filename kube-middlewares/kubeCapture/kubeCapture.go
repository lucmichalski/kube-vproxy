package kubeCapture

import (
	"bufio"
	"errors"
	"fmt"
	"net/http"
	"log"
	"strconv"
	"io"
	"strings"
	"github.com/vulcand/vulcand/plugin"
)

const Type = "kubeCapture"

func GetSpec() *plugin.MiddlewareSpec {
	return &plugin.MiddlewareSpec{
		Type:      Type,
		FromOther: FromOther,
	}
}

// KubeCaptureMiddleware struct holds configuration parameters and is used to
// serialize/deserialize the configuration from storage engines.
type KubeCaptureMiddleware struct {
	Status          int
	Body            string
	BodyWithHeaders string
}

// KubeCapture middleware handler
type KubeCaptureHandler struct {
	status  int
	headers map[string]string
	body    string
	next    http.Handler
}

// This function will be called each time the request hits the location with this middleware activated
func (s *KubeCaptureHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	var connect, results, result, connectFmt string
	connectFmt = ""
	connect = strings.Replace(s.body, "\"[]\"", "\"[#]\"", 1)
	log.Printf("connect template loaded: %s", connect)
	log.Print("\r\nFINAL RESULT - START ===================== \r\n")
	for header, value := range s.headers {
		log.Printf("%T, %v\n", header, header)
		log.Printf("%T, %v\n", value, value)
		if header == "X-Kube-Vmx-Matched" {
			matched := strings.Split(value, "|")
			log.Printf("%v, %v\n", matched[0], matched[1])
			if score, err := strconv.ParseFloat(matched[0], 64); err == nil {
				log.Printf("%T, %v\n", score, score)
				if score > 0 {
					w.Header().Get(header)
					log.Printf("%v", fmt.Sprintf("Header: %v, Value: %v", header, value))
					result = fmt.Sprint("{", "\"ID\":", string(matched[1]), ",\"Score\":", 0, ",\"Keywords\":", "[]", "},")	
					results += string(result)
				}
			}
		}
		w.Header().Set(header, value)
	}
	for header := range r.Header {
		log.Printf("%T, %v\n", header, header)
		if header == "X-Kube-Vmx-Matched" {
			value := w.Header().Get(header)
			log.Printf("%T, %v\n", value, value)
			matched := strings.Split(value, "|")
			log.Printf("%v, %v\n", matched[0], matched[1])
			if score, err := strconv.ParseFloat(matched[0], 64); err == nil {
				log.Printf("%T, %v\n", score, score)
				if score > 0 {
					log.Printf("%v", fmt.Sprintf("Header: %v, Value: %v", header, value))
					result = fmt.Sprint("{", "\"ID\":", matched[1], ",\"Score\":", 0, ",\"Keywords\":", "[]", "},")	
//					results = append(results, result)
					results += string(result)
				}
			}
		}
//		w.Header().Set(header[:], value[:])
	}
	if len(results) > 0 {
		connectFmt = results[0:len(results)-1]
	}

	log.Printf("marker chain identified: %s", connectFmt)
	output := strings.Replace(connect, "#", connectFmt, 1)
	log.Printf("output: %s", output)
	log.Print("\r\nFINAL RESULT - END ===================== \r\n")
	w.WriteHeader(http.StatusOK)
	w.Header().Set("X-Middleware-Name", "KubeCapture")
	w.Header().Set("X-Middleware-Result", "Generated")
	w.Header().Set("Content-Type", "application/json; charset=utf-8") // normal header
	w.Header().Set("Content-Length", fmt.Sprintf("%v", len(output)))
    io.WriteString(w, output) 
	r.Body.Close()
} 

// This function is optional but handy, used to check input parameters when creating new middlewares
func New(status int, body, bodyWithHeaders string) (*KubeCaptureMiddleware, error) {
	if bodyWithHeaders != "" {
		if _, _, err := parseBodyWithHeaders(bodyWithHeaders); err != nil {
			return nil, fmt.Errorf("BodyWithHeaders did not parse: %v", err)
		}
	}
	return &KubeCaptureMiddleware{Status: status, Body: body, BodyWithHeaders: bodyWithHeaders}, nil
}

// This function is important, it's called by vulcand to create a new handler from the middleware config and put it into the
// middleware chain. Note that we need to remember 'next' handler to call
func (c *KubeCaptureMiddleware) NewHandler(next http.Handler) (http.Handler, error) {
	body := c.Body
    fmt.Printf("%s", string(body))
	headers := make(map[string]string)
	if c.BodyWithHeaders != "" {
		// It's already registered so we know there's no error
		headers, body, _ = parseBodyWithHeaders(c.BodyWithHeaders)
	}

	return &KubeCaptureHandler{next: next, status: c.Status, headers: headers, body: body}, nil
}

// String() will be called by loggers inside Vulcand and command line tool.
func (c *KubeCaptureMiddleware) String() string {
	return fmt.Sprintf("Static: status %d", c.Status)
}

// Function should return middleware interface and error in case if the parameters are wrong.
func FromOther(c KubeCaptureMiddleware) (plugin.Middleware, error) {
	return New(c.Status, c.Body, c.BodyWithHeaders)
}

// Utility Functions

func isStatusValid(status int) bool {
	log.Println("Current status", status)
	return status >= 100 && status <= 599
}

func parseBodyWithHeaders(fullBody string) (headers map[string]string, body string, err error) {
	headers = make(map[string]string)
	s := bufio.NewScanner(strings.NewReader(fullBody))

	// headers
	for s.Scan() {
		line := strings.TrimSpace(s.Text())
		log.Println("Parsing the header line", line)
		if line == "" {
			break
		}
		tokens := strings.Split(line, ": ")
		if len(tokens) != 2 {
			err = fmt.Errorf("Header failed to parse: %v", line)
			return
		}
		headers[tokens[0]] = tokens[1]
	}

	if len(headers) == 0 {
		err = errors.New("BodyWithHeaders must contain at least one header.")
		return
	}

	// body
	bodylines := []string{}
	for s.Scan() {
		bodylines = append(bodylines, s.Text())
		log.Println("Parsing Body Line: ", bodylines)

	}

	// Process our results here !
	/*
	{
		 "Status": {
		   "Code": 400
		 }
	}
	{	"Results": output,
		"Status": {	
			"Code": 0
		}
	}
	*/

	// ScanLines strips the newline off the last line if it had one
	body = strings.Join(bodylines, "\n")
	log.Println("End of the parsing process")
	return
}