# gemini-telemetry (Go CLI)

A tiny Go CLI that tails a Gemini telemetry `.logl` file, printing each new event's name and (when present) the prompt text. It only follows new records, mirroring `tail -F`.

## Build & Run

```bash
cd gemini-telemetry
# run without installing
GO111MODULE=on go run . --file /path/to/gemini.logl --prompt-limit 128

# or build once
GO111MODULE=on go build -o gemini-telemetry
./gemini-telemetry --file /path/to/gemini.logl
```

Flags:

- `--file`, `-f`: path to the telemetry log (default `./gemini.logl`).
- `--prompt-limit`, `-p`: number of tokens to print from each prompt (default `256`).

The CLI starts at the end of the current log and prints only new events as they arrive. On log rotation or truncation it automatically reopens the file and continues streaming.
