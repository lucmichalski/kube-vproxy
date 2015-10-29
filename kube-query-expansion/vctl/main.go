package main

import (
    "github.com/mailgun/log"
        "github.com/mailgun/vulcand/vctl/command"
        "github.com/blippar/kube-vproxy-plugins/kube-query-expansion/registry"
        "os"
)

var vulcanUrl string

func main() {

    log.NewConsoleLogger(log.Config{log.Console, "info"}) 

    r, err := registry.GetRegistry()
        if err != nil {
                log.Errorf("Error: %s\n", err)
        return
        }
        cmd := command.NewCommand(r)
        if err := cmd.Run(os.Args); err != nil {
                log.Errorf("Error: %s\n", err)
        }
}
