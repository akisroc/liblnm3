#include "lib.h"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

// void solve_battle(const BattleStateNotation initial_state, BattleLogNotation *battle_log) {
//     srand(time(NULL));
//     // Deciding who goes first

// }

void parse_troup(const TroupNotation troup_notation, Troup troup) {
    TroupNotation str_buffer = {0};
    strcpy(str_buffer, troup_notation);

    char *token = strtok(str_buffer, "/");
    for (unsigned short int i = 0; token != NULL; ++i) {
        troup[i] = atof(token);
        token = strtok(nullptr, "/");
    }
}

void serialize_troup(const Troup troup, const size_t troup_size, TroupNotation troup_notation) {
    UnitNotation buffer = {0};
    for (size_t i = 0; i < troup_size; ++i) {
        snprintf(buffer, sizeof(buffer), "%0*d", UNIT_PADDING_SIZE, troup[i]);
        strcat(troup_notation, buffer);
        if (i < troup_size - 1) {
            strcat(troup_notation, "/");
        }
    }
}

// void solve_battle(const BattleStateNotation initial_state, BattleLogNotation *battle_log) {
//
// }
