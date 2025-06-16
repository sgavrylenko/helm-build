package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"
)

const DELAY_SECONDS = 1

func main() {
	// Create a context that will be canceled on OS signals
	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer cancel() // Ensure cancel is called on exit

	var wg sync.WaitGroup

	wg.Add(1)
	go func() {
		defer wg.Done()
		ticker := time.NewTicker(time.Second * DELAY_SECONDS)
		defer ticker.Stop()

		for {
			select {
			case <-ticker.C:
				log.Println("I'm alive!")
			case <-ctx.Done():
				log.Println("I'm shutting down! :-(")
				os.Exit(0)
			}
		}
	}()

	<-ctx.Done()
	wg.Wait()
}
