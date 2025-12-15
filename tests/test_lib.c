#include "../src/lib.h"
#include <assert.h>
#include <stdio.h>

#define FMT_GREEN "\033[32m"
#define FMT_RED "\033[31m"
#define FMT_RESET "\033[0m"
#define FMT_BOLD "\033[1m"

#define DISPLAY_SUCCESS() printf(FMT_BOLD FMT_GREEN "OK ----> " FMT_RESET FMT_BOLD "%s()\n" FMT_RESET, __func__)

int test_init_piece(void) {
    const Piece piece = init_piece(PIECE_TYPE_P1);
    assert(piece.id == PIECE_TYPE_P1);
    assert(piece.type == PIECE_TYPE_P1);
    assert(piece.attack == PIECE_ATTACK_P1);
    assert(piece.defense == PIECE_DEFENSE_P1);
    assert(piece.speed == PIECE_SPEED_P1);

    Piece pieces[7];
    const int max = sizeof(pieces) / sizeof(Piece);
    for (int i = 0; i < max; ++i) {
        pieces[i] = init_piece(PIECE_TYPE_P3);
        printf("%d\n", pieces[i].defense);
    }

    DISPLAY_SUCCESS();

    return 0;
}

int main(void) {
    test_init_piece();

    return 0;
}
