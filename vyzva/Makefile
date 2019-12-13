TARGET = chytrak freq shift

CC = gcc
CCFLAGS += -Wall -Wextra


chytrak: chytrak.c
		$(CC) $(CCFLAGS) $< -o $@

freq: freq.c
		$(CC) $(CCFLAGS) $< -o $@

shift: shift.c
		$(CC) $(CCFLAGS) $< -o $@

all: $(TARGET)

clean:
		@rm -f $(TARGET) vysledeksifry.txt vysledekdruhesifry.txt


rebuild: clean $(TARGET)
