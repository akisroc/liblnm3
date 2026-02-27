package uuidv7

import "github.com/google/uuid"

type V7Generator struct{}

func (g *V7Generator) Generate() (string, error) {
	id, err := uuid.NewV7()

	return id.String(), err
}
