/*
** EPITECH PROJECT, 2025
** pokemon_red
** File description:
** map_destroyer
*/

#include "pkm_map.h"

#include <stdlib.h>

void destroy_map(pokemon_map_t *map)
{
    if (map == NULL)
        return;
    if (map->filepath != NULL)
        free(map->filepath);
    free(map->map);
    free(map);
}
