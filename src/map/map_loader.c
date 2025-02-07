/*
** EPITECH PROJECT, 2025
** pokemon_red
** File description:
** map_loader
*/

#include "pkm_map.h"
#include "pkm_logger.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

static int process_map(char *)
{

}

static int load_tile(
    char *filepath,
    pokemon_map_t *)
{
    FILE *file = fopen(filepath, "r");
    char buffer[512] = { 0 };

    if (file == NULL)
        return 84;
    for (char line[512] = { 0 }; fgets(line, sizeof(line), file); ) {
        line[strcspn(line, "\n")] = 0;
        printf("File Content: '%s'\n", line);
    }
    fclose(file);
    return 0;
}

pokemon_map_t *load_map(
    game_context_t *context,
    char *filepath)
{
    pokemon_map_t *pokemon_map = malloc(sizeof(pokemon_map_t));

    pokemon_map->filepath = strdup(filepath);
    pokemon_map->map = malloc(sizeof(pokemon_tile_t) * 100); // TODO Edit this :)
    if (pokemon_map == NULL ||
            pokemon_map->filepath == NULL ||
            pokemon_map->map == NULL) {
        destroy_map(pokemon_map);
        return NULL;
    }
    if (load_tile(filepath, pokemon_map) == 84) {
        LOG_ERROR(context, "Erro while loading map tile(s) at %s.", filepath);
        destroy_map(pokemon_map);
        return NULL;
    }
    return pokemon_map;
}
