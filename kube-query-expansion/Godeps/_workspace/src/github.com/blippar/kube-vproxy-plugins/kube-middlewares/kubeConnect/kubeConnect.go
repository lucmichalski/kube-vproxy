package kubeConnect

import (
	"bufio"
	"errors"
	"fmt"
	"net/http"
	"log"
//	"strconv"
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
	w.WriteHeader(s.status)
	w.Header().Set("X-Middleware-Name", "KubeConnect")
	for header, value := range s.headers {
		w.Header().Set(header, value)
	}
	/*
	log.Println(string(body))
	log.Println("Body Request: \n", body)
	log.Printf("The kubeConnect Middleware was reached, Body Lenght: %f", len(s.body))
	log.Println("Body to send: \n", s.body)
	*/
	w.Header().Set("Content-Type", "application/json; charset=utf-8") // normal header
	w.WriteHeader(http.StatusOK)
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Content-Length", fmt.Sprintf("%v", len(s.body)))
	w.Write(s.body)
	r.Body.Close()
} 

// This function is optional but handy, used to check input parameters when creating new middlewares
func New(status int, body, bodyWithHeaders string) (*KubeConnectMiddleware, error) {
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

// Utility Functions

func isStatusValid(status int) bool {
	log.Println("Current status", status)
	return status >= 100 && status <= 599
}

func (b *bufferWriter) Close() error {
	return b.buffer.Close()
}

func (b *bufferWriter) Header() http.Header {
	return b.header
}

func (b *bufferWriter) Write(buf []byte) (int, error) {
	return b.buffer.Write(buf)
}

// WriteHeader sets rw.Code.
func (b *bufferWriter) WriteHeader(code int) {
	b.code = code
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