TARGET = game pokus

CC = g++
CCFLAGS += -Wall -Wextra -I/usr/include/SDL2


game: piskvorky.cpp
		$(CC) $(CCFLAGS) $< -o $@

pokus: to_same.cpp
		$(CC) $(CCFLAGS) $< -o $@

all: $(TARGET)

clean:
		@rm -f $(TARGET)


rebuild: clean $(TARGET)
