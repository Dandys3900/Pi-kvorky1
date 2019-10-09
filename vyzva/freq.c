#include <stdio.h>
#include <ctype.h>


int main(int argc, char *argv[]) {

	if (argc > 1) {
		FILE *f = fopen(argv[1], "rb");
		int c;
		int freq[256] = {0,};
		int total = 0;

		while ((c = fgetc(f)) != EOF) {
			if (isalpha(c)) {
				c = tolower(c);
				freq[c]++;
				total++;
			}
		}
		fclose(f);

		for (c = 'a'; c <= 'z'; c++) {
			printf("%c = %1.6f %%\n", c, (double)freq[c] * 100 / total);
		}
	}

	return 0;
}
