package registry

import (
	"github.com/vulcand/vulcand/plugin"
	
	"github.com/vulcand/vulcand/plugin/connlimit"
	
	"github.com/vulcand/vulcand/plugin/ratelimit"
	
	"github.com/vulcand/vulcand/plugin/rewrite"
	
	"github.com/vulcand/vulcand/plugin/cbreaker"
	
	"github.com/vulcand/vulcand/plugin/trace"
	
	"github.com/blippar/kube-vproxy/kube-middlewares/kubeDispatcher"
	
	"github.com/blippar/kube-vproxy/kube-middlewares/kubeOCR"

        "github.com/blippar/kube-vproxy/kube-middlewares/kubeConnect"
	
)

func GetRegistry() (*plugin.Registry, error) {
	r := plugin.NewRegistry()

	specs := []*plugin.MiddlewareSpec{
		
		connlimit.GetSpec(),
       
		ratelimit.GetSpec(),
       
		rewrite.GetSpec(),
       
		cbreaker.GetSpec(),
       
		trace.GetSpec(),
       
		kubeDispatcher.GetSpec(),
       
		kubeOCR.GetSpec(),

                kubeConnect.GetSpec(),
       
	}

	for _, spec := range specs {
		if err := r.AddSpec(spec); err != nil {
			return nil, err
		}
	}
	return r, nil
}
