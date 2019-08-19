TARGET = game

CC = g++
CCFLAGS += -Wall -Wextra


$(TARGET): piskvorky.cpp
		$(CC) $(CCFLAGS) $^ -o $@

clean:
		@rm -f $(TARGET)


rebuild: clean $(TARGET)
