package main

import (
	"github.com/coreos/etcd/client"
	etcderr "github.com/coreos/etcd/error"
	"golang.org/x/net/context"
	"reflect"
	"testing"
)

func TestReadServices(t *testing.T) {
	etcd, err := client.New(client.Config{Endpoints: []string{"http://localhost:2379"}})
	if err != nil {
		t.Fatal(err)
	}
	kapi := client.NewKeysAPI(etcd)

	if err := deleteRecursiveIfExists(kapi, "/vulcand/"); err != nil {
		t.Error(err)
	}

	if err := setValues(kapi, map[string]string{
		"/ft/services/service-a/healthcheck":        "true",
		"/ft/services/service-a/servers/srv1":       "http://host1:1",
		"/ft/services/service-a/path-regex/bananas": "/bananas/.*",
		"/ft/services/service-b/healthcheck":        "false",
		"/ft/services/service-b/servers/srv1":       "http://host1:1",
		"/ft/services/service-b/servers/srv2":       "http://host2:2",
		"/ft/services/service-b/path-regex/content": "/content/.*",
		"/ft/services/service-b/path-regex/bananas": "/bananas/.*",
	}); err != nil {
		t.Error(err)
	}

	smap := make(map[string]Service)
	for _, s := range readServices(kapi) {
		smap[s.Name] = s
	}
	if len(smap) != 2 {
		t.Fatal("unexpected length")
	}

	a := Service{
		Name:           "service-a",
		HasHealthCheck: true,
		Addresses:      map[string]string{"srv1": "http://host1:1"},
		PathPrefixes: map[string]string{
			"bananas": "/bananas/.*",
		},
	}

	if !reflect.DeepEqual(a, smap["service-a"]) {
		t.Errorf("service does not match. expected and acual are :\n%v\n%v\n", a, smap["service-a"])
	}

	b := Service{
		Name:           "service-b",
		HasHealthCheck: false,
		Addresses: map[string]string{
			"srv1": "http://host1:1",
			"srv2": "http://host2:2",
		},
		PathPrefixes: map[string]string{
			"bananas": "/bananas/.*",
			"content": "/content/.*",
		},
	}
	if !reflect.DeepEqual(b, smap["service-b"]) {
		t.Errorf("service does not match:\n%v\n%v\n", b, smap["service-b"])
	}
}

func TestBuildVulcanConfSingleBackend(t *testing.T) {
	a := Service{
		Name:           "service-a",
		HasHealthCheck: true,
		Addresses:      map[string]string{"srv1": "http://host1:1"},
		PathPrefixes: map[string]string{
			"bananas": "/bananas/.*",
			"cheese":  "/cheese/.*",
		},
	}

	vc := buildVulcanConf([]Service{a})

	expected := vulcanConf{
		Backends: map[string]vulcanBackend{
			"vcb-service-a": vulcanBackend{
				Servers: map[string]vulcanServer{
					"srv1": vulcanServer{"http://host1:1"},
				},
			},
			"vcb-service-a-srv1": vulcanBackend{
				Servers: map[string]vulcanServer{
					"srv1": vulcanServer{"http://host1:1"},
				},
			},
		},
		FrontEnds: map[string]vulcanFrontend{
			"vcb-byhostheader-service-a": vulcanFrontend{
				BackendID: "vcb-service-a",
				Route:     "PathRegexp(`/.*`) && Host(`service-a`)",
				Type:      "http",
			},
			"vcb-internal-service-a": vulcanFrontend{
				BackendID: "vcb-service-a",
				Route:     "PathRegexp(`/__service-a/.*`)",
				Type:      "http",
				rewrite: vulcanRewrite{
					Id:       "rewrite",
					Type:     "rewrite",
					Priority: 1,
					Middleware: vulcanRewriteMw{
						Regexp:      "/__service-a(/.*)",
						Replacement: "$1",
					},
				},
			},
			"vcb-health-service-a-srv1": vulcanFrontend{
				BackendID: "vcb-service-a-srv1",
				Route:     "Path(`/health/service-a-srv1/__health`)",
				Type:      "http",
				rewrite: vulcanRewrite{
					Id:       "rewrite",
					Type:     "rewrite",
					Priority: 1,
					Middleware: vulcanRewriteMw{
						Regexp:      "/health/service-a-srv1(.*)",
						Replacement: "$1",
					},
				},
			},
			"vcb-service-a-path-regex-bananas": vulcanFrontend{
				BackendID: "vcb-service-a",
				Route:     "PathRegexp(`/bananas/.*`)",
				Type:      "http",
			},
			"vcb-service-a-path-regex-cheese": vulcanFrontend{
				BackendID: "vcb-service-a",
				Route:     "PathRegexp(`/cheese/.*`)",
				Type:      "http",
			},
		},
	}

	if !reflect.DeepEqual(expected, vc) {
		t.Errorf("vulcan conf failed. expected and actual are:\n%v\n%v\n", expected, vc)
	}

}

func TestApplyVulcanConfigInitial(t *testing.T) {
	etcd, err := client.New(client.Config{Endpoints: []string{"http://localhost:2379"}})
	if err != nil {
		t.Fatal(err)
	}
	kapi := client.NewKeysAPI(etcd)

	if err := deleteRecursiveIfExists(kapi, "/vulcand/"); err != nil {
		t.Error(err)
	}

	// should run despite no frontends/ and backends/ directories existing.
	applyVulcanConf(kapi, vulcanConf{})
}

func TestApplyVulcanConfigRemoval(t *testing.T) {
	etcd, err := client.New(client.Config{Endpoints: []string{"http://localhost:2379"}})
	if err != nil {
		t.Fatal(err)
	}
	kapi := client.NewKeysAPI(etcd)

	if err := deleteRecursiveIfExists(kapi, "/vulcand/"); err != nil {
		t.Error(err)
	}

	if err := setValues(kapi, map[string]string{
		"/vulcand/backends/foo/backend":                  `{"Type": "http"}`,
		"/vulcand/backends/foo/servers/s1":               `{"url":"http://host1.baz.com:12345"}`,
		"/vulcand/backends/vcb-foo/backend":              `{"Type": "http"}`,
		"/vulcand/backends/vcb-foo/servers/s1":           `{"url":"http://host1.baz.com:12345"}`,
		"/vulcand/frontends/foo/frontend":                `{"Type":"http", "BackendId":"foo", "Route":"Path(\"foo-b\")"}`,
		"/vulcand/frontends/foo/middlewares/rewrite":     `{"Id":"rewrite", "Type":"rewrite", "Priority":1, "Middleware": {"Regexp":"/foo/(.*)", "Replacement":"$1"}}`,
		"/vulcand/frontends/vcb-foo/frontend":            `{"Type":"http", "BackendId":"vcb-foo", "Route":"Path(\"foo-a\")"}`,
		"/vulcand/frontends/vcb-foo/middlewares/rewrite": `{"Id":"rewrite", "Type":"rewrite", "Priority":1, "Middleware": {"Regexp":"/foo/(.*)", "Replacement":"$1"}}`,
	}); err != nil {
		t.Error(err)
	}

	applyVulcanConf(kapi, vulcanConf{})

	after, err := readAllKeysFromEtcd(kapi, "/vulcand/")
	if err != nil {
		t.Error(err)
	}

	expected := map[string]string{
		"/vulcand/backends/foo/backend":              `{"Type": "http"}`,
		"/vulcand/backends/foo/servers/s1":           `{"url":"http://host1.baz.com:12345"}`,
		"/vulcand/frontends/foo/frontend":            `{"Type":"http", "BackendId":"foo", "Route":"Path(\"foo-b\")"}`,
		"/vulcand/frontends/foo/middlewares/rewrite": `{"Id":"rewrite", "Type":"rewrite", "Priority":1, "Middleware": {"Regexp":"/foo/(.*)", "Replacement":"$1"}}`,
	}

	if !reflect.DeepEqual(expected, after) {
		t.Errorf("fail. expected and actual are \n%v\n%v\n", expected, after)
	}
}

func TestApplyVulcanConfigCreate(t *testing.T) {
	etcd, err := client.New(client.Config{Endpoints: []string{"http://localhost:2379"}})
	if err != nil {
		t.Fatal(err)
	}
	kapi := client.NewKeysAPI(etcd)

	if err := deleteRecursiveIfExists(kapi, "/vulcand/"); err != nil {
		t.Error(err)
	}

	vc := vulcanConf{
		Backends: map[string]vulcanBackend{
			"vcb-service-a": vulcanBackend{
				Servers: map[string]vulcanServer{
					"srv1": vulcanServer{"http://host1:1"},
				},
			},
			"vcb-service-a-srv1": vulcanBackend{
				Servers: map[string]vulcanServer{
					"srv1": vulcanServer{"http://host1:1"},
				},
			},
		},
		FrontEnds: map[string]vulcanFrontend{
			"vcb-byhostheader-service-a": vulcanFrontend{
				BackendID: "vcb-service-a",
				Route:     "PathRegexp(`/.*`) && Host(`service-a`)",
				Type:      "http",
			},
			"vcb-health-service-a-srv1": vulcanFrontend{
				BackendID: "vcb-service-a-srv1",
				Route:     "Path(`/health/service-a-srv1/__health`)",
				Type:      "http",
				rewrite: vulcanRewrite{
					Id:       "rewrite",
					Type:     "rewrite",
					Priority: 1,
					Middleware: vulcanRewriteMw{
						Regexp:      "/health/service-a-srv1(.*)",
						Replacement: "$1",
					},
				},
			},
			"vcb-service-a-path-regex-bananas": vulcanFrontend{
				BackendID: "vcb-service-a",
				Route:     "PathRegexp(`/bananas/.*`)",
				Type:      "http",
			},
			"vcb-service-a-path-regex-toast": vulcanFrontend{
				BackendID: "vcb-service-a",
				Route:     "PathRegexp(`/toast/.*`)",
				Type:      "http",
			},
		},
	}

	applyVulcanConf(kapi, vc)

	values, err := readAllKeysFromEtcd(kapi, "/vulcand/")
	if err != nil {
		t.Error(err)
	}

	expected := map[string]string{
		"/vulcand/backends/vcb-service-a/backend":                          `{"Type":"http"}`,
		"/vulcand/backends/vcb-service-a/servers/srv1":                     `{"url":"http://host1:1"}`,
		"/vulcand/backends/vcb-service-a-srv1/backend":                     `{"Type":"http"}`,
		"/vulcand/backends/vcb-service-a-srv1/servers/srv1":                `{"url":"http://host1:1"}`,
		"/vulcand/frontends/vcb-byhostheader-service-a/frontend":           "{\"Type\":\"http\", \"BackendId\":\"vcb-service-a\", \"Route\":\"PathRegexp(`/.*`) && Host(`service-a`)\"}",
		"/vulcand/frontends/vcb-health-service-a-srv1/frontend":            "{\"Type\":\"http\", \"BackendId\":\"vcb-service-a-srv1\", \"Route\":\"Path(`/health/service-a-srv1/__health`)\"}",
		"/vulcand/frontends/vcb-health-service-a-srv1/middlewares/rewrite": `{"Id":"rewrite", "Type":"rewrite", "Priority":1, "Middleware": {"Regexp":"/health/service-a-srv1(.*)", "Replacement":"$1"}}`,
		"/vulcand/frontends/vcb-service-a-path-regex-bananas/frontend":     "{\"Type\":\"http\", \"BackendId\":\"vcb-service-a\", \"Route\":\"PathRegexp(`/bananas/.*`)\"}",
		"/vulcand/frontends/vcb-service-a-path-regex-toast/frontend":       "{\"Type\":\"http\", \"BackendId\":\"vcb-service-a\", \"Route\":\"PathRegexp(`/toast/.*`)\"}",
	}

	if !reflect.DeepEqual(expected, values) {
		t.Errorf("fail. expected and actual are \n%v\n%v\n", expected, values)
	}
}

// TODO: mock stuff to ensure nothing is actually updated when replacing config with itself
func TestApplyVulcanConfigReplaceIdentical(t *testing.T) {
	etcd, err := client.New(client.Config{Endpoints: []string{"http://localhost:2379"}})
	if err != nil {
		t.Fatal(err)
	}
	kapi := client.NewKeysAPI(etcd)

	if err := deleteRecursiveIfExists(kapi, "/vulcand/"); err != nil {
		t.Error(err)
	}

	vc := vulcanConf{
		Backends: map[string]vulcanBackend{
			"vcb-service-a": vulcanBackend{
				Servers: map[string]vulcanServer{
					"s1": vulcanServer{"http://hostz:1"},
				},
			},
			"vcb-service-a-s1": vulcanBackend{
				Servers: map[string]vulcanServer{
					"s1": vulcanServer{"http://hostz:1"},
				},
			},
		},
		FrontEnds: map[string]vulcanFrontend{
			"vcb-byhostheader-service-a": vulcanFrontend{
				BackendID: "vcb-service-a",
				Route:     "PathRegexp(`/.*`) && Host(`service-a`)",
				Type:      "http",
			},
			"vcb-health-service-a-s1": vulcanFrontend{
				BackendID: "vcb-service-a-s1",
				Route:     "Path(`/health/service-a-s1/__health`)",
				Type:      "http",
				rewrite: vulcanRewrite{
					Id:       "rewrite",
					Type:     "rewrite",
					Priority: 1,
					Middleware: vulcanRewriteMw{
						Regexp:      "/health/service-a-s1(.*)",
						Replacement: "$1",
					},
				},
			},
			"vcb-service-a-path-regex-toast1": vulcanFrontend{
				BackendID: "vcb-service-a",
				Route:     "PathRegexp(`/toast1/.*`)",
				Type:      "http",
			},
		},
	}

	applyVulcanConf(kapi, vc)
	// replace with itself
	println("ying")
	applyVulcanConf(kapi, vc)

	values, err := readAllKeysFromEtcd(kapi, "/vulcand/")
	if err != nil {
		t.Error(err)
	}

	expected := map[string]string{
		"/vulcand/backends/vcb-service-a/backend":                        `{"Type":"http"}`,
		"/vulcand/backends/vcb-service-a/servers/s1":                     `{"url":"http://hostz:1"}`,
		"/vulcand/backends/vcb-service-a-s1/backend":                     `{"Type":"http"}`,
		"/vulcand/backends/vcb-service-a-s1/servers/s1":                  `{"url":"http://hostz:1"}`,
		"/vulcand/frontends/vcb-byhostheader-service-a/frontend":         "{\"Type\":\"http\", \"BackendId\":\"vcb-service-a\", \"Route\":\"PathRegexp(`/.*`) && Host(`service-a`)\"}",
		"/vulcand/frontends/vcb-health-service-a-s1/frontend":            "{\"Type\":\"http\", \"BackendId\":\"vcb-service-a-s1\", \"Route\":\"Path(`/health/service-a-s1/__health`)\"}",
		"/vulcand/frontends/vcb-health-service-a-s1/middlewares/rewrite": `{"Id":"rewrite", "Type":"rewrite", "Priority":1, "Middleware": {"Regexp":"/health/service-a-s1(.*)", "Replacement":"$1"}}`,
		"/vulcand/frontends/vcb-service-a-path-regex-toast1/frontend":    "{\"Type\":\"http\", \"BackendId\":\"vcb-service-a\", \"Route\":\"PathRegexp(`/toast1/.*`)\"}",
	}

	if !reflect.DeepEqual(expected, values) {
		t.Errorf("fail. expected and actual are \n%v\n%v\n", expected, values)
	}
}

func TestApplyVulcanConfigReplace(t *testing.T) {
	etcd, err := client.New(client.Config{Endpoints: []string{"http://localhost:2379"}})
	if err != nil {
		t.Fatal(err)
	}
	kapi := client.NewKeysAPI(etcd)

	if err := deleteRecursiveIfExists(kapi, "/vulcand/"); err != nil {
		t.Error(err)
	}

	applyVulcanConf(kapi, vulcanConf{
		Backends: map[string]vulcanBackend{
			"vcb-service-a": vulcanBackend{
				Servers: map[string]vulcanServer{
					"srv1": vulcanServer{"http://host1:1"},
				},
			},
			"vcb-service-a-srv1": vulcanBackend{
				Servers: map[string]vulcanServer{
					"srv1": vulcanServer{"http://host1:1"},
				},
			},
		},
		FrontEnds: map[string]vulcanFrontend{
			"vcb-byhostheader-service-a": vulcanFrontend{
				BackendID: "vcb-service-a",
				Route:     "PathRegexp(`/.*`) && Host(`service-a`)",
				Type:      "http",
			},
			"vcb-health-service-a-srv1": vulcanFrontend{
				BackendID: "vcb-service-a-srv1",
				Route:     "Path(`/health/service-a-srv1/__health`)",
				Type:      "http",
				rewrite: vulcanRewrite{
					Id:       "rewrite",
					Type:     "rewrite",
					Priority: 1,
					Middleware: vulcanRewriteMw{
						Regexp:      "/health/service-a-srv1(.*)",
						Replacement: "$1",
					},
				},
			},
			"vcb-service-a-path-regex-bananas": vulcanFrontend{
				BackendID: "vcb-service-a",
				Route:     "PathRegexp(`/bananas/.*`)",
				Type:      "http",
			},
			"vcb-service-a-path-regex-toast": vulcanFrontend{
				BackendID: "vcb-service-a",
				Route:     "PathRegexp(`/toast/.*`)",
				Type:      "http",
			},
		},
	})

	applyVulcanConf(kapi, vulcanConf{
		Backends: map[string]vulcanBackend{
			"vcb-service-a": vulcanBackend{
				Servers: map[string]vulcanServer{
					"s1": vulcanServer{"http://hostz:1"},
				},
			},
			"vcb-service-a-s1": vulcanBackend{
				Servers: map[string]vulcanServer{
					"s1": vulcanServer{"http://hostz:1"},
				},
			},
		},
		FrontEnds: map[string]vulcanFrontend{
			"vcb-byhostheader-service-a": vulcanFrontend{
				BackendID: "vcb-service-a",
				Route:     "PathRegexp(`/.*`) && Host(`service-a`)",
				Type:      "http",
			},
			"vcb-health-service-a-s1": vulcanFrontend{
				BackendID: "vcb-service-a-s1",
				Route:     "Path(`/health/service-a-s1/__health`)",
				Type:      "http",
				rewrite: vulcanRewrite{
					Id:       "rewrite",
					Type:     "rewrite",
					Priority: 1,
					Middleware: vulcanRewriteMw{
						Regexp:      "/health/service-a-s1(.*)",
						Replacement: "$1",
					},
				},
			},
			"vcb-service-a-path-regex-toast1": vulcanFrontend{
				BackendID: "vcb-service-a",
				Route:     "PathRegexp(`/toast1/.*`)",
				Type:      "http",
			},
		},
	})

	values, err := readAllKeysFromEtcd(kapi, "/vulcand/")
	if err != nil {
		t.Error(err)
	}

	expected := map[string]string{
		"/vulcand/backends/vcb-service-a/backend":                        `{"Type":"http"}`,
		"/vulcand/backends/vcb-service-a/servers/s1":                     `{"url":"http://hostz:1"}`,
		"/vulcand/backends/vcb-service-a-s1/backend":                     `{"Type":"http"}`,
		"/vulcand/backends/vcb-service-a-s1/servers/s1":                  `{"url":"http://hostz:1"}`,
		"/vulcand/frontends/vcb-byhostheader-service-a/frontend":         "{\"Type\":\"http\", \"BackendId\":\"vcb-service-a\", \"Route\":\"PathRegexp(`/.*`) && Host(`service-a`)\"}",
		"/vulcand/frontends/vcb-health-service-a-s1/frontend":            "{\"Type\":\"http\", \"BackendId\":\"vcb-service-a-s1\", \"Route\":\"Path(`/health/service-a-s1/__health`)\"}",
		"/vulcand/frontends/vcb-health-service-a-s1/middlewares/rewrite": `{"Id":"rewrite", "Type":"rewrite", "Priority":1, "Middleware": {"Regexp":"/health/service-a-s1(.*)", "Replacement":"$1"}}`,
		"/vulcand/frontends/vcb-service-a-path-regex-toast1/frontend":    "{\"Type\":\"http\", \"BackendId\":\"vcb-service-a\", \"Route\":\"PathRegexp(`/toast1/.*`)\"}",
	}

	if !reflect.DeepEqual(expected, values) {
		t.Errorf("fail. expected and actual are \n%v\n%v\n", expected, values)
	}
}

func setValues(kapi client.KeysAPI, kvs map[string]string) error {
	for k, v := range kvs {
		if _, err := kapi.Set(context.Background(), k, v, &client.SetOptions{}); err != nil {
			return err
		}
	}
	return nil
}

func deleteRecursiveIfExists(kapi client.KeysAPI, path string) (err error) {
	_, err = kapi.Delete(context.Background(), path, &client.DeleteOptions{Recursive: true})
	if e, _ := err.(client.Error); e.Code == etcderr.EcodeKeyNotFound {
		// ignore not found.
		err = nil
	}
	return err

}
