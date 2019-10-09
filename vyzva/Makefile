TARGET = freq

CC = gcc
CCFLAGS += -Wall -Wextra


freq: freq.c
		$(CC) $(CCFLAGS) $< -o $@

all: $(TARGET)

clean:
		@rm -f $(TARGET)


rebuild: clean $(TARGET)
