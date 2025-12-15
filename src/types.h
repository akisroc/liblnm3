#ifndef LIBLNM3_TYPES_H
#define LIBLNM3_TYPES_H

typedef unsigned short int PieceId;
typedef unsigned short int PieceAttribute;

typedef enum {
    PIECE_TYPE_P1, PIECE_TYPE_P2, PIECE_TYPE_P3, PIECE_TYPE_P4,
    PIECE_TYPE_P5, PIECE_TYPE_P6, PIECE_TYPE_P7, PIECE_TYPE_P8
} PieceType;

typedef enum {
    PIECE_ATTACK_P1 = 4, PIECE_ATTACK_P2 = 3, PIECE_ATTACK_P3 = 5, PIECE_ATTACK_P4 = 5,
    PIECE_ATTACK_P5 = 18, PIECE_ATTACK_P6 = 10, PIECE_ATTACK_P7 = 24, PIECE_ATTACK_P8 = 19
} PieceAttack;

typedef enum {
    PIECE_DEFENSE_P1 = 7, PIECE_DEFENSE_P2 = 5, PIECE_DEFENSE_P3 = 9, PIECE_DEFENSE_P4 = 7,
    PIECE_DEFENSE_P5 = 8, PIECE_DEFENSE_P6 = 7, PIECE_DEFENSE_P7 = 16, PIECE_DEFENSE_P8 = 13
} PieceDefense;

typedef enum {
    PIECE_SPEED_P1 = 85, PIECE_SPEED_P2 = 86, PIECE_SPEED_P3 = 95, PIECE_SPEED_P4 = 84,
    PIECE_SPEED_P5 = 80, PIECE_SPEED_P6 = 98, PIECE_SPEED_P7 = 88, PIECE_SPEED_P8 = 90
} PieceSpeed;

typedef struct Piece {
    PieceId id;
    PieceType type;
    PieceAttack attack;
    PieceDefense defense;
    PieceSpeed speed;
} Piece;

#endif // LIBLNM3_TYPES_H
