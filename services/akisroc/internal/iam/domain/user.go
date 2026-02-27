package entity

import (
	"errors"
	"regexp"
	"time"
)

type User struct {
	id             string
	nickname       string
	email          string
	password       string
	profilePicture string
	slug           string
	roles          []string // Todo: Enum
	platformTheme  string
	isEnabled      bool
	isRemoved      bool
	insertedAt     time.Time
	updatedAt      time.Time
}

var (
	ErrInvalidNickname = errors.New("Invalid nickname format")
	nicknameRegex      = regexp.MustCompile(`^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ\'’\-_\.&]{1,30}$`)

	ErrInvalidEmail = errors.New("Invalid email format")
	emailRegex      = regexp.MustCompile(`^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$`)
)

func New(id, nickname, email, password string) (*User, error) {
	if !nicknameRegex.MatchString(nickname) {
		return nil, ErrInvalidNickname
	}

	if !emailRegex.MatchString(email) {
		return nil, ErrInvalidEmail
	}

	return &User{
		id:       id,
		nickname: nickname,
		email:    email,
		password: password,
	}, nil
}
