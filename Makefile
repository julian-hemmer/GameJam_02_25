##
## EPITECH PROJECT, 2025
## pokemon_red
## File description:
## Binary Makefile
##

SRC	= \
	src/main.c

INCLUDE	=	-iquote./include -iquote./include/util

WARNING	=	-Wall -Wextra

CFLAGS	= 	$(WARNING) $(INCLUDE) -g

OBJ		= 	$(SRC:src/%.c=build/obj/%.o)

LIBS	=	-lcsfml-window -lcsfml-graphics -lcsfml-system -lm

NAME	= 	Archilusion

build/obj/%.o : src/%.c
	@mkdir -p $@
	@rmdir $@
	@echo "\e[94mCompiled [\e[95m$@\e[94m]\n"\
		"    |-> using [\e[90m$(CFLAGS)\e[94m]\e[0m"
	@$(CC) -c -o "$@" $(CFLAGS) "$<"

all: $(NAME)

re: fclean $(NAME)

$(NAME): $(OBJ)
	@mkdir -p build/out/
	@echo
	@echo "\e[32mCompiling \e[31m.o \e[32mto executable binary:\e[90m"
	gcc -o build/out/$(NAME) $(OBJ) $(INCLUDE) $(LIBS)
	@echo "\033[A\e[0m"
	@cp build/out/$(NAME) .

clean:
	@echo "\e[92mRemove following directory: [\e[90mbuild/obj\e[92m]"
	@rm -rf build/obj/

fclean:
	@echo "\e[92mRemove following directory: [\e[90mbuild\e[92m]"
	@rm -rf build/

	@echo "\e[92mRemove following file: [\e[90m$(NAME), *.gcda, *.gcdo\e[92m]"
	@rm -f $(NAME) *.gcda *.gcdo
