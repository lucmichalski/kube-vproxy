package kubeLtu763

//
// Luc Michalski - 2015
// Kube Vision - kube OCR Processing (Unit tests to do)
//

import (
	"io"
	"net/http"
	"net/http/httptest"
	"github.com/vulcand/vulcand/Godeps/_workspace/src/github.com/codegangsta/cli"
	"github.com/vulcand/vulcand/Godeps/_workspace/src/github.com/mailgun/oxy/testutils"
	. "github.com/vulcand/vulcand/Godeps/_workspace/src/gopkg.in/check.v1"
	"github.com/vulcand/vulcand/plugin"
	"testing"
)

func TestCL(t *testing.T) { TestingT(t) }

type kubeLtu763Suite struct {
}

var _ = Suite(&kubeLtu763Suite{})

// One of the most important tests:
// Make sure the RateLimit spec is compatible and will be accepted by middleware registry
func (s *kubeLtu763Suite) TestSpecIsOK(c *C) {
	c.Assert(plugin.NewRegistry().AddSpec(GetSpec()), IsNil)
}

func (s *kubeLtu763Suite) TestNew(c *C) {
	cl, err := New("user", "pass")
	c.Assert(cl, NotNil)
	c.Assert(err, IsNil)
	c.Assert(cl.String(), Not(Equals), "")
	out, err := cl.NewHandler(nil)
	c.Assert(out, NotNil)
	c.Assert(err, IsNil)
}

func (s *kubeLtu763Suite) TestNewBadParams(c *C) {
	// Empty pass
	_, err := New("user", "")
	c.Assert(err, NotNil)
	// Empty user
	_, err = New("", "pass")
	c.Assert(err, NotNil)
}

func (s *kubeLtu763Suite) TestFromOther(c *C) {
	a, err := New("user", "pass")
	c.Assert(a, NotNil)
	c.Assert(err, IsNil)

	out, err := FromOther(*a)
	c.Assert(err, IsNil)
	c.Assert(out, DeepEquals, a)
}

func (s *kubeLtu763Suite) TestkubeLtu763FromCli(c *C) {
	app := cli.NewApp()
	app.Name = "test"
	executed := false
	app.Action = func(ctx *cli.Context) {
		executed = true
		out, err := FromCli(ctx)
		c.Assert(out, NotNil)
		c.Assert(err, IsNil)
		a := out.(*kubeLtu763Middleware)
		c.Assert(a.Password, Equals, "pass1")
		c.Assert(a.Username, Equals, "user1")
	}
	app.Flags = CliFlags()
	app.Run([]string{"test", "--user=user1", "--pass=pass1"})
	c.Assert(executed, Equals, true)
}

func (s *kubeLtu763Suite) TestRequestSuccess(c *C) {
	a := &kubeLtu763Middleware{Username: "aladdin", Password: "open sesame"}

	h := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		io.WriteString(w, "treasure")
	})

	dispatcher, err := a.NewHandler(h)
	c.Assert(err, IsNil)

	srv := httptest.NewServer(dispatcher)
	defer srv.Close()

	_, body, err := testutils.Get(srv.URL, testutils.BasicAuth(a.Username, a.Password))
	c.Assert(err, IsNil)
	c.Assert(string(body), Equals, "treasure")
}

func (s *kubeLtu763Suite) TestRequestBadPassword(c *C) {
	a := &kubeLtu763Middleware{Username: "aladdin", Password: "open sesame"}

	h := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		io.WriteString(w, "treasure")
	})

	dispatcher, err := a.NewHandler(h)
	c.Assert(err, IsNil)

	srv := httptest.NewServer(dispatcher)
	defer srv.Close()

	// bad pass
	re, _, err := testutils.Get(srv.URL, testutils.BasicAuth(a.Username, "open please"))
	c.Assert(err, IsNil)
	c.Assert(re.StatusCode, Equals, http.StatusForbidden)

	// missing header
	re, _, err = testutils.Get(srv.URL)
	c.Assert(err, IsNil)
	c.Assert(re.StatusCode, Equals, http.StatusForbidden)

	// malformed header
	re, _, err = testutils.Get(srv.URL, testutils.Header("Authorization", "blablabla="))
	c.Assert(err, IsNil)
	c.Assert(re.StatusCode, Equals, http.StatusForbidden)
}