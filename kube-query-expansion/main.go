package main

import (
	"fmt"
	"github.com/blippar/kube-vproxy/kube-query-expansion/registry"
	"github.com/vulcand/vulcand/service"
	"os"
)

func main() {
	r, err := registry.GetRegistry()
	if err != nil {
		fmt.Printf("Service exited with error: %s\n", err)
		os.Exit(255)
	}
	if err := service.Run(r); err != nil {
		fmt.Printf("Service exited with error: %s\n", err)
		os.Exit(255)
	} else {
		fmt.Println("Service exited gracefully")
	}
}
