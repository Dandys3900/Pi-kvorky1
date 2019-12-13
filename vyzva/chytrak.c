#include <stdio.h>  // printf(), fgetc(), getchar(), putchar()
#include <ctype.h>  // isalpha(), toupper()
#include <unistd.h> // getopt()
#include <stdlib.h> // exit()
#include <string.h> // memset()

void usage(void) {
	fprintf(stderr, "./chytrak [-s number] [-h] cvicnytext.txt statistika.txt\n" \
					"\t-s number .. how many characters should be shifted/rotated (number)\n" \
					"\t-h ......... prints this usage\n\n");
	fprintf(stderr, "Decrypts standard input and prints to standard output.\n");
	exit(1);
}

// how many letters are in alphabet (should be 26, but more intuitive)
#define cLetters ('Z' - 'A' + 1)

// structure describing the frequency of each letter
typedef struct {
	unsigned total;
	unsigned freq[cLetters];
} freq_table;

// calculates frequency of letters in file from first parameter
// frequency table is written to freq table descriptor
void calc_freq(const char *filename, freq_table *out) {
	FILE *f = fopen(filename, "rt");
	if (!f) {
		fprintf(stderr, "Filename '%s' cannot be opened for reading!\n", filename);
		exit(2);
	}

	// fills the whole structure with zeroes
	memset(out, 0, sizeof(freq_table));

	int c;
	while ((c = fgetc(f)) != EOF) {
		if (isalpha(c)) {
			out->freq[toupper(c) - 'A']++;
			out->total++;
		}
	}
	fclose(f);
}

// read frequencies from statistics file and adapts all letters to read freq table
void read_statistics(const char *filename, const freq_table *in, freq_table *out) {
	FILE *f = fopen(filename, "rt");
	if (!f) {
		fprintf(stderr, "Filename '%s' cannot be opened for reading!\n", filename);
		exit(2);
	}

	char c;
	double freq;
	while (!feof(f)) {
		// parse line: a = #.####### %
		fscanf(f, "%c = %lf %%\n", &c, &freq);
		if (isalpha(c)) {
			// plus 50 works like round() when dividing by 100
			out->freq[toupper(c) - 'A'] = (freq * in->total + 50) / 100;
		} else
			fprintf(stderr, "Bad syntax in file '%s'\n", filename);
	}
	out->total = in->total;
}

// compares frequencies 'from' and 'to' and create mapping accordingly
// if the match is ambiguous, the first one will be applied
// note: parameter 'to' is a copy
void make_mapping(const freq_table *from, freq_table to, char *mapping) {
	int i, j;
	for (i = 0; i < cLetters; i++) {
		for (j = 0; j < cLetters; j++) {
			if (from->freq[i] == to.freq[j]) {
				mapping[i] = j;
				// this letter should be ignored in further processing
				to.freq[j] = to.total;
				break;
			}
		}
	}
}

// apply character mapping to x
char decode_char(const char *mapping, char x) {
	if (isalpha(x)) {
		if (islower(x))
			return mapping[x - 'a'] + 'a';
		else
			return mapping[x - 'A'] + 'A';
	} else
		return x;
}

// shift/rotate character by shift parameter
// note: unsigned char is important when reaching ascii code 128+
char rotate_char(unsigned char x, char shift) {
	if (isalpha(x)) {
		if (islower(x)) {
			x += shift;
			while (x > 'z')
				x -= cLetters;
			while (x < 'a')
				x += cLetters;
		} else {
			x += shift;
			while (x > 'Z')
				x -= cLetters;
			while (x < 'A')
				x += cLetters;
		}
	}
	return x;
}

// reads standard input, decode character according to character mapping
// applies shift parameter to part between lines with ****
// output is written to standard output
void decode_input(const char *mapping, char shift) {
	enum { HEADER, FIRST_SEPARATOR, BODY, SECOND_SEPARATOR, FOOTER } q = HEADER;
	int c;
	while ((c = getchar()) != EOF) {
		switch (q) {
		case HEADER: case FOOTER:
			putchar(decode_char(mapping, c));
			if (c == '*')
				q++;
			break;
		case FIRST_SEPARATOR: case SECOND_SEPARATOR:
			putchar(c);
			if (c == '\n')
				q++;
			break;
		case BODY:
			putchar(rotate_char(decode_char(mapping, c), shift));
			if (c == '*')
				q = 3;
			break;
		default:
			fprintf(stderr, "Unexpected state!\n");
		}
	}
}

int main(int argc, char *argv[]) {
	int opt;
	char shift = -3;

	// classical parameter handling via std library
	while ((opt = getopt(argc, argv, "s:h")) != -1) {
		switch (opt) {
		case 'h':
			usage();
		case 's':
			shift = atoi(optarg);
			if (!shift) {
				fprintf(stderr, "Number of shifts should be nonzero amount!\n\n");
				usage();
			}
			break;
		}
	}
	if (optind + 2 < argc) {
		fprintf(stderr, "Too many parameters...\n\n");
		usage();
	}
	if (optind + 2 > argc) {
		fprintf(stderr, "Missing mandatory parameters!\n\n");
		usage();
	}

	freq_table example, stats;
	calc_freq(argv[optind], &example);
	read_statistics(argv[optind + 1], &example, &stats);

	char mapping[cLetters];
	make_mapping(&example, stats, mapping);

	decode_input(mapping, shift);

	return 0;
}
