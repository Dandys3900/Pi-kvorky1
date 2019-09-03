TARGET = game pokus

CC = g++
CCFLAGS += -Wall -Wextra


game: piskvorky.cpp
		$(CC) $(CCFLAGS) $< -o $@

pokus: to_same.cpp
		$(CC) $(CCFLAGS) $< -o $@

all: $(TARGET)

clean:
		@rm -f $(TARGET)


rebuild: clean $(TARGET)
