package main

func consumeBuffer(buffer []byte, handler recordHandler) []byte {
	start := -1
	depth := 0
	inString := false
	escapeNext := false

	for i := 0; i < len(buffer); i++ {
		b := buffer[i]

		if inString {
			if escapeNext {
				escapeNext = false
				continue
			}
			if b == '\\' {
				escapeNext = true
				continue
			}
			if b == '"' {
				inString = false
			}
			continue
		}

		switch b {
		case '"':
			inString = true
		case '{':
			if depth == 0 {
				start = i
			}
			depth++
		case '}':
			if depth == 0 {
				continue
			}
			depth--
			if depth == 0 && start >= 0 {
				end := i + 1
				handler(buffer[start:end])
				buffer = buffer[end:]
				i = -1
				start = -1
			}
		}
	}

	return buffer
}
