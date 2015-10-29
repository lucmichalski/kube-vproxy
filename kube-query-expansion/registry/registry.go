package registry

import (
	"github.com/mailgun/vulcand/plugin"
	
	"github.com/mailgun/vulcand/plugin/connlimit"
	
	"github.com/mailgun/vulcand/plugin/ratelimit"
	
	"github.com/mailgun/vulcand/plugin/rewrite"
	
	"github.com/mailgun/vulcand/plugin/cbreaker"
	
	"github.com/mailgun/vulcand/plugin/trace"
	
	"github.com/blippar/kube-vproxy-plugins/kube-middlewares/kubeDispatcher"
	
	"github.com/blippar/kube-vproxy-plugins/kube-middlewares/kubeOCR"
	
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
       
	}

	for _, spec := range specs {
		if err := r.AddSpec(spec); err != nil {
			return nil, err
		}
	}
	return r, nil
}
