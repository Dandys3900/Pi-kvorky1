#include <stdio.h>
#include <stdlib.h>

// operator % jako zbytek po celociselnem deleni je zaporny pro zaporna cisla
// proto si to radeji osetrim
int modulo(int x, int divisor) {
	return (x >= 0) ? x % divisor : x % divisor + divisor;
}

int main() {
	char volba[3], command[10];
	// mapovani pismen a cislic
	char pozadi[] = "dbcef";
	char popredi[] = "01249";
	while (1) {
		printf("Zadej barevnou kombinaci ('q' pro konec):\n");
		scanf("%2s", volba);
		if (*volba == 'q')
			break;
		sprintf(command, "color %c%c", pozadi[modulo(volba[0]-'a', 5)], popredi[modulo(volba[1]-'1', 5)]);
		system(command);
		printf("vstup '%s', vystup '%s'\n", volba, command);
		system("color 0f");
	}
	printf("Goodbye sucker!\n");
	return 0;
}
