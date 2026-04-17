package main

import (
	"encoding/json"
	"fmt"
	"strings"
)

type telemetryRecord map[string]any

func newRecordProcessor(promptLimit int) recordHandler {
	if promptLimit <= 0 {
		promptLimit = 1
	}

	return func(data []byte) {
		var record telemetryRecord
		if err := json.Unmarshal(data, &record); err != nil {
			return
		}

		attrVal, ok := record["attributes"].(map[string]any)
		if !ok {
			return
		}

		eventName, _ := attrVal["event.name"].(string)
		if eventName == "" {
			return
		}

		timestamp, _ := attrVal["event.timestamp"].(string)
		if timestamp == "" {
			timestamp = "unknown"
		}

		fields := collectFields(eventName, attrVal)
		header := fmt.Sprintf("[%s] %s", timestamp, eventName)
		if len(fields) > 0 {
			header = header + " | " + strings.Join(fields, " | ")
		}
		fmt.Println(header)

		switch eventName {
		case "gemini_cli.model_routing":
			printRoutingDetails(attrVal)
		case "gemini_cli.api_response", "gemini_cli.api_request":
			printAPIDetails(attrVal)
		}

		if prompt, _ := attrVal["prompt"].(string); prompt != "" {
			display, total, truncated := limitPrompt(prompt, promptLimit)
			shown := promptLimit
			if total < promptLimit {
				shown = total
			}
			suffix := fmt.Sprintf("(showing %d/%d tokens)", shown, total)
			if truncated {
				suffix += " …"
			}
			fmt.Printf("    prompt %s: %s\n", suffix, display)
		}
	}
}

func collectFields(eventName string, attrs map[string]any) []string {
	keys := []string{
		"prompt_id",
		"model",
		"session.id",
		"installation.id",
		"decision_model",
		"decision_source",
		"routing_latency_ms",
	}

	fields := make([]string, 0, len(keys)+1)
	for _, key := range keys {
		if value, ok := attrs[key]; ok {
			fields = append(fields, fmt.Sprintf("%s=%v", key, value))
		}
	}

	if eventName == "gemini_cli.model_routing" {
		if failed, ok := attrs["failed"].(bool); ok {
			fields = append(fields, fmt.Sprintf("failed=%t", failed))
		}
	}

	return fields
}

func printRoutingDetails(attrs map[string]any) {
	reasoning, _ := attrs["reasoning"].(string)
	if reasoning != "" {
		fmt.Printf("    reasoning: %s\n", reasoning)
	}
	if explanation, ok := attrs["explanation"].(string); ok && explanation != "" {
		fmt.Printf("    explanation: %s\n", explanation)
	}
}

func printAPIDetails(attrs map[string]any) {
	if requestText, ok := attrs["request_text"].(string); ok && requestText != "" {
		fmt.Println("    request:")
		fmt.Println(indentBlock(requestText, 8))
	}
	if responseText, ok := attrs["response_text"].(string); ok && responseText != "" {
		fmt.Println("    response:")
		fmt.Println(indentBlock(responseText, 8))
	}
}

func indentBlock(text string, spaces int) string {
	pad := strings.Repeat(" ", spaces)
	lines := strings.Split(text, "\n")
	for i, line := range lines {
		lines[i] = pad + line
	}
	return strings.Join(lines, "\n")
}

func limitPrompt(prompt string, limit int) (display string, total int, truncated bool) {
	tokens := strings.Fields(prompt)
	total = len(tokens)
	if total == 0 {
		return "", 0, false
	}
	if total <= limit {
		return prompt, total, false
	}
	displayTokens := tokens[:limit]
	return strings.Join(displayTokens, " "), total, true
}
