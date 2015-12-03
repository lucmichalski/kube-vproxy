# vulcan-config-builder

A simple application to interpret FT etcd service configuration and apply our routing policies to it, and setting the corresponding vulcand configuration in etcd.

Instead of configuring vulcand directly in etcd, this tool allows a more declarative approach, and keeps all of the policy logic about how to configure vulcand elsewhere (i.e., in this application)

Example
```
etcdctl set   /ft/services/service-a/healthcheck            true
etcdctl set   /ft/services/service-a/servers/1             "http://host:5678" --ttl 600
etcdctl set   /ft/services/service-a/path-regex/list       /lists/.*
etcdctl set   /ft/services/service-a/path-regex/content    /content/.*
```

will result in

```
# "main" backend & server(s)
/vulcand/backends/vcb-service-a-1/backend      {"Type":"http"}
/vulcand/backends/vcb-service-a-1/servers/1    {"url":"http://host:5678"}

# instance backend & server(s)
/vulcand/backends/vcb-service-a/backend      {"Type":"http"}
/vulcand/backends/vcb-service-a/servers/1    {"url":"http://host:5678"}

# internal routing frontend
/vulcand/frontends/vcb-internal-service-a/frontend            {"Type":"http", "BackendId":"vcb-service-a", "Route":"PathRegexp(`/__service-a/.*`)"}
/vulcand/frontends/vcb-internal-service-a/middlewares/rewrite {"Id":"rewrite", "Type":"rewrite", "Priority":1, "Middleware": {"Regexp":"/__service-a(/.*)", "Replacement":"$1"}}

# health check routing
/vulcand/frontends/vcb-health-service-a-1/frontend             {"Type":"http", "BackendId":"vcb-service-a-1", "Route":"Path(`/health/service-a-1/__health`)"}
/vulcand/frontends/vcb-health-service-a-1/middlewares/rewrite  {"Id":"rewrite", "Type":"rewrite", "Priority":1, "Middleware": {"Regexp":"/health/service-a-1(.*)", "Replacement":"$1"}}

# host header based routing
/vulcand/frontends/vcb-byhostheader-service-a/frontend      {"Type":"http", "BackendId":"vcb-service-a", "Route":"PathRegexp(`/.*`) && Host(`service-a`)"}

# "public" routing
/vulcand/frontends/vcb-service-a-path-regex-content/frontend {"Type":"http", "BackendId":"vcb-service-a", "Route":"PathRegexp(`/content/.*`)"}
/vulcand/frontends/vcb-service-a-path-regex-list/frontend    {"Type":"http", "BackendId":"vcb-service-a", "Route":"PathRegexp(`/content/.*`)"}

```

These routing rules will change as we develop. The idea is they are in a single place in this application, not spread out across many unmaintainable sidekick services.
