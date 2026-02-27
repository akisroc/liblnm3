package uuidv7

import "github.com/google/uuid"

func IsValidUUIDv7(s string) bool {
	parsed, err := uuid.Parse(s)
	if err != nil {
		return false
	}

	return parsed.Version() == 7
}
