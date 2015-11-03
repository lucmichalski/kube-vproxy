package kubeOrientation

import (
	"bytes"
	"image"
	"image/draw"
	"image/jpeg"
	"log"
	"github.com/disintegration/imaging"	
	"github.com/rwcarlsen/goexif/exif"
)

const Type = "kubeOrientation"

func GetSpec() *plugin.MiddlewareSpec {
	return &plugin.MiddlewareSpec{
		Type:      Type,
		FromOther: FromOther,
	}
}

// StaticMiddleware struct holds configuration parameters and is used to
// serialize/deserialize the configuration from storage engines.
type KubeConnectMiddleware struct {
	Status          int
	Body            string
	BodyWithHeaders string
}

// Static middleware handler
type StaticHandler struct {
	status  int
	headers map[string]string
	body    string
	next    http.Handler
}

// This function will be called each time the request hits the location with this middleware activated
func (s *StaticHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(s.status)
	for header, value := range s.headers {
		w.Header().Set(header, value)
	}
	w.Header().Set("Content-Length", strconv.Itoa(len(s.body)))
	io.WriteString(w, s.body)
}

// This function is optional but handy, used to check input parameters when creating new middlewares
func New(status int, body, bodyWithHeaders string) (*StaticMiddleware, error) {
	if !isStatusValid(status) {
		return nil, fmt.Errorf("Status must be between 100 and 599")
	}
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
	return status >= 100 && status <= 599
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