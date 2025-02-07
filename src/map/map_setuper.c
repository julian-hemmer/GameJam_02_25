/*
** EPITECH PROJECT, 2025
** pokemon_red
** File description:
** map_setuper
*/

#include "pkm_map.h"

int setup_map(game_context_t *context)
{
    context->map = load_map(context, "./data/dev_map");
    return 0;
}