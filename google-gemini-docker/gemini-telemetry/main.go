package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"
)

const (
	defaultLogPath = "gemini.logl"
	defaultPrompt  = 256
)

func main() {
	logPath := flag.String("file", defaultLogPath, "Path to gemini telemetry log file")
	flag.StringVar(logPath, "f", defaultLogPath, "Path to gemini telemetry log file")
	promptLimit := flag.Int("prompt-limit", defaultPrompt, "Maximum number of tokens to display for prompts")
	flag.IntVar(promptLimit, "p", defaultPrompt, "Maximum number of tokens to display for prompts")
	flag.Parse()

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	fmt.Printf("[telemetry] Following %s (new events only)\n", *logPath)

	processor := newRecordProcessor(*promptLimit)
	if err := followFile(ctx, *logPath, processor); err != nil {
		if errors.Is(err, context.Canceled) {
			fmt.Println("[telemetry] Stopped")
			return
		}
		fmt.Fprintf(os.Stderr, "[telemetry] error: %v\n", err)
		os.Exit(1)
	}
}
