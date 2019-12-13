#include <stdio.h>
#include <ctype.h>

int main(int argc, char *argv[]) {

	if (argc > 1) {
		FILE *f = fopen(argv[1], "rb");
		int c;

		while ((c = fgetc(f)) != EOF) {
			if (isalpha(c)) {
				c -= 3;
				if (!isalpha(c))
					c += 26;
			}
			putchar(c);
		}
		fclose(f);
	}
	return 0;
}
