package kubeConnect

import (
	"bufio"
	"errors"
	"fmt"
	"net/http"
	"log"
	"strconv"
	"bytes"
	"io"
	"strings"
	"github.com/vulcand/vulcand/plugin"
)

const Type = "kubeConnect"

func GetSpec() *plugin.MiddlewareSpec {
	return &plugin.MiddlewareSpec{
		Type:      Type,
		FromOther: FromOther,
	}
}

// KubeConnectMiddleware struct holds configuration parameters and is used to
// serialize/deserialize the configuration from storage engines.
type KubeConnectMiddleware struct {
	Status          int
	Body            string
	BodyWithHeaders string
}

// KubeConnect middleware handler
type KubeConnectHandler struct {
	status  int
	headers map[string]string
	body    string
	next    http.Handler
}

// This function will be called each time the request hits the location with this middleware activated
func (s *KubeConnectHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	results := &bytes.Buffer{}
	log.Print("\r\nFINAL RESULT - START ===================== \r\n")
	log.Print("\r\nREQUEST HEADERS FROM PREVIOUS MIDDLEWARE - START ===================== \r\n")
	for header, value := range s.headers {
		log.Printf("%T, %v\n", header, header)
		log.Printf("%T, %v\n", value, value)
		if header == "X-Kube-Vmx-Matched" {
			matched := strings.Split(value, "|")
			log.Printf("MarkerId=%v, Score=%v, Entity=%v\n", matched[0], matched[1], matched[2])
			if score, err := strconv.ParseFloat(matched[0], 64); err == nil {
				log.Printf("%T, %v\n", score, score)
				if score > 0 {
					w.Header().Get(header)
					log.Printf("%v", fmt.Sprintf("Header: %v, Value: %v", header, value))
					result := fmt.Sprint("{", "\"ID\":", string(matched[1]), ",\"Score\":", score, ",\"Keywords\":", "[\""+matched[2]+"\"]", "},")	
					results.WriteString(result)
				}
			}
		}
		w.Header().Set(header, value)
		w.Header().Set("X-Middleware-Prev-Headers", "Parsed")
	}

	log.Print("\r\nREQUEST HEADERS FROM PREVIOUS MIDDLEWARE - END ===================== \r\n")
	log.Print("\r\nREQUEST HEADERS - START ===================== \r\n")
	for header := range r.Header {
		log.Printf("%T, %v\n", header, header)
		if header == "X-Kube-Vmx-Matched" {
			value := r.Header.Get(header)
			log.Printf("%T, %v\n", value, value)
			matched := strings.Split(value, "|")
			log.Printf("%v, %v\n", matched[0], matched[1])
			if score, err := strconv.ParseFloat(matched[0], 64); err == nil {
				log.Printf("%T, %v\n", score, score)
				if score > 0 {
					log.Printf("%v", fmt.Sprintf("Header: %v, Value: %v", header, value))
					result := fmt.Sprint("{", "\"ID\":", matched[1], ",\"Score\":", score, ",\"Keywords\":", "[\""+matched[2]+"\"]", "},")	
					results.WriteString(result)
				}
			}
		}
		w.Header().Set("X-Middleware-Req-Headers", "Parsed")
	}

	log.Print("\r\nREQUEST HEADERS - END ===================== \r\n")
	log.Print("\r\nRESPONSE HEADERS - START ===================== \r\n")

	for header := range w.Header() {
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
					result := fmt.Sprint("{", "\"ID\":", matched[1], ",\"Score\":", score, ",\"Keywords\":", "[\""+matched[2]+"\"]", "},")	
					results.WriteString(result)
				}
			}
		}
		w.Header().Set("X-Middleware-Response-Headers", "Parsed")
	}
	log.Print("\r\nRESPONSE HEADERS - END ===================== \r\n")
	log.Printf("results length: %s", strconv.Itoa(results.Len()))
	if results.Len() > 0 {
		log.Printf("results chain: %s", results)
		connectFmt := results.String()
		connectFmt = connectFmt[0:len(connectFmt)-1]
		log.Printf("marker chain identified: %s", connectFmt)
		s.body = strings.Replace(s.body, "CONNECTME", "["+string(connectFmt)+"]", 1)
	} else {
		s.body = strings.Replace(s.body, "CONNECTME", "[]", 1)		
	}
	log.Printf("output: %s", s.body)
	log.Print("\r\nFINAL RESULT - END ===================== \r\n")
	w.WriteHeader(http.StatusOK)
	w.Header().Set("X-Middleware-Name", "KubeConnect")
	w.Header().Set("X-Middleware-Result", "Generated")
	w.Header().Set("Content-Type", "application/json; charset=utf-8") // normal header
	w.Header().Set("Content-Length", fmt.Sprintf("%v", len(s.body)))
	io.WriteString(w, s.body)
	r.Body.Close()
} 

// This function is optional but handy, used to check input parameters when creating new middlewares
func New(status int, body, bodyWithHeaders string) (*KubeConnectMiddleware, error) {

	log.Print("\r\nBODY FROM NEW - START ===================== \r\n")
	log.Printf("%T\n", body)
    log.Printf("%s", string(body))
    log.Printf("%s", string(bodyWithHeaders))
	log.Print("\r\nBODY FROM NEW - END ===================== \r\n")


	if bodyWithHeaders != "" {
		if _, _, err := parseBodyWithHeaders(bodyWithHeaders); err != nil {
			return nil, fmt.Errorf("BodyWithHeaders did not parse: %v", err)
		}
	}
	return &KubeConnectMiddleware{Status: status, Body: body, BodyWithHeaders: bodyWithHeaders}, nil
}

// This function is important, it's called by vulcand to create a new handler from the middleware config and put it into the
// middleware chain. Note that we need to remember 'next' handler to call
func (c *KubeConnectMiddleware) NewHandler(next http.Handler) (http.Handler, error) {
	body := c.Body
	log.Print("\r\nBODY FROM PREVIOUS MIDDLEWARE - START ===================== \r\n")
    log.Printf("%s", string(body))
	log.Print("\r\nBODY FROM PREVIOUS MIDDLEWARE - END ===================== \r\n")
	headers := make(map[string]string)
	if c.BodyWithHeaders != "" {
		// It's already registered so we know there's no error
		headers, body, _ = parseBodyWithHeaders(c.BodyWithHeaders)
	}

	return &KubeConnectHandler{next: next, status: c.Status, headers: headers, body: body}, nil
}

// String() will be called by loggers inside Vulcand and command line tool.
func (c *KubeConnectMiddleware) String() string {
	return fmt.Sprintf("Static: status %d", c.Status)
}

// Function should return middleware interface and error in case if the parameters are wrong.
func FromOther(c KubeConnectMiddleware) (plugin.Middleware, error) {
	return New(c.Status, c.Body, c.BodyWithHeaders)
}

func parseBodyWithHeaders(fullBody string) (headers map[string]string, body string, err error) {
	headers = make(map[string]string)
	s := bufio.NewScanner(strings.NewReader(fullBody))

	// headers
	for s.Scan() {
		line := strings.TrimSpace(s.Text())
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
	}

	// ScanLines strips the newline off the last line if it had one
	body = strings.Join(bodylines, "\n")
	return
}