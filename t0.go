package main

import (
	"fmt"
	"github.com/cs439t-f25/layer2"
	"log"
	"p7/impl"
	"sync"
	"time"
)

var wg sync.WaitGroup = sync.WaitGroup{}
var mgr layer2.Mgr

// host1 behavior
func host1() {

	err := mgr.IfConfig(layer2.NewMacAddr(1, 2), "host1")
	if err != nil {
		panic(fmt.Errorf("host1: failed to get config manager: %v", err))
	}

	log.Printf("host1 configured\n")

	c, err := mgr.Connect(10, 29, "host2")
	if err != nil {
		panic(fmt.Errorf("host1: failed to connect to host2: %v", err))
	}

	log.Printf("host1 connected %v\n", c)

	c.ToNetwork <- 42

}

// host2 behvaior
func host2() {
	err := mgr.IfConfig(layer2.NewMacAddr(10, 29), "host2")
	if err != nil {
		panic(fmt.Errorf("host2: failed to get config manager: %v", err))
	}

	c, err := mgr.Listen(29)
	if err != nil {
		panic(fmt.Errorf("host2: failed to listen on port 29: %v", err))
	}

	val := <-c.FromNetwork
	if val != 42 {
		panic(fmt.Errorf("host2: expected 42, got %v", val))
	}

	fmt.Printf("%v\n", val)
}

func main() {
	// disable logging, enable if needed for debugging
	//log.SetOutput(io.Discard)
	s := layer2.NewSwitch(200, 10, .1, .0)

	var err error

	mgr, err = impl.NewMgr(s)
	if err != nil {
		panic(fmt.Errorf("failed to create ConfigMgr: %v", err))
	}

	done := make(chan bool)

	go func() {
		wg.Go(host1)
		wg.Go(host2)
		wg.Wait()
		done <- true
	}()

	select {
	case <-done:
		fmt.Println("Test completed")
	case <-time.After(20 * time.Second):
		fmt.Println("Test timed out")
	}
}
