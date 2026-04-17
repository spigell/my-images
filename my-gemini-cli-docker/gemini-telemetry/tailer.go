package main

import (
	"context"
	"errors"
	"io"
	"os"
	"time"
)

const (
	pollInterval  = 250 * time.Millisecond
	readChunkSize = 4096
)

type recordHandler func([]byte)

func followFile(ctx context.Context, path string, handler recordHandler) error {
	file, info, offset, err := openFile(path, true)
	if err != nil {
		return err
	}
	defer file.Close()

	buffer := make([]byte, 0, readChunkSize)
	chunk := make([]byte, readChunkSize)

	for {
		select {
		case <-ctx.Done():
			return context.Canceled
		default:
		}

		n, readErr := file.Read(chunk)
		if n > 0 {
			buffer = append(buffer, chunk[:n]...)
			offset += int64(n)
			buffer = consumeBuffer(buffer, handler)
		}

		if readErr != nil {
			if errors.Is(readErr, io.EOF) {
				if err := waitForData(ctx); err != nil {
					return err
				}
				reopen, reopenErr := shouldReopen(path, info, offset)
				if reopenErr != nil {
					return reopenErr
				}
				if reopen {
					if err := file.Close(); err != nil {
						return err
					}
					for {
						newFile, newInfo, newOffset, err := openFile(path, false)
						if err != nil {
							if os.IsNotExist(err) {
								if err := waitForData(ctx); err != nil {
									return err
								}
								continue
							}
							return err
						}
						file = newFile
						info = newInfo
						offset = newOffset
						buffer = buffer[:0]
						break
					}
				}
				continue
			}
			return readErr
		}
	}
}

func openFile(path string, seekEnd bool) (*os.File, os.FileInfo, int64, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, nil, 0, err
	}

	info, err := file.Stat()
	if err != nil {
		file.Close()
		return nil, nil, 0, err
	}

	var offset int64
	if seekEnd {
		offset, err = file.Seek(0, io.SeekEnd)
	} else {
		offset, err = file.Seek(0, io.SeekStart)
	}
	if err != nil {
		file.Close()
		return nil, nil, 0, err
	}

	return file, info, offset, nil
}

func waitForData(ctx context.Context) error {
	select {
	case <-ctx.Done():
		return context.Canceled
	case <-time.After(pollInterval):
		return nil
	}
}

func shouldReopen(path string, currentInfo os.FileInfo, offset int64) (bool, error) {
	stat, err := os.Stat(path)
	if err != nil {
		if os.IsNotExist(err) {
			return true, nil
		}
		return false, err
	}

	if currentInfo == nil || !os.SameFile(currentInfo, stat) {
		return true, nil
	}

	if stat.Size() < offset {
		return true, nil
	}

	return false, nil
}
