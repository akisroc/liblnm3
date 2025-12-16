#ifndef LIBLNM3_LIB_H
#define LIBLNM3_LIB_H

#include "types.h"
#include "stddef.h"

/**
 * Parse troup notation and hydrates given Troup array.
 *
 * @param troup_notation
 * @param troup /!\ This will be mutated
 */
void parse_troup(const TroupNotation troup_notation, Troup troup);

/**
 * Serialize troup array and hydrates given TroupNotation string.
 *
 * @param troup
 * @param troup_notation /!\ This will be mutated
 */
void serialize_troup(const Troup troup, size_t troup_size, TroupNotation troup_notation);

#endif // LIBLNM3_LIB_H
