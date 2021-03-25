/* gcc mkff.c -o mkff && ./mkff height width bg fg | feh - */

#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

typedef size_t usize;
typedef uint64_t u64;
typedef uint32_t u32;
typedef uint16_t u16;

int
main(int argc, char **argv)
{
	// Parse arguments.
	if (argc < 5) return 1;
	u64 height = strtol(argv[1], NULL,  0);
	u64 width  = strtol(argv[2], NULL,  0);
	u32 bg     = strtol(argv[3], NULL, 16);
	u32 fg     = strtol(argv[4], NULL, 16);

	// Output farbfeld headers.
	u32 tmp;
	fputs("farbfeld", stdout);
	tmp = htonl(width);
	fwrite(&tmp, sizeof(tmp), 1, stdout);
	tmp = htonl(height);
	fwrite(&tmp, sizeof(tmp), 1, stdout);

	u16 buf[height][width * (4 * sizeof(u16))];

	for (usize y = 0; y < height; ++y) {
		for (usize x = 0; x < width; ++x) {
			u32 c = getchar() == '0' ? bg : fg,
                            r = (c >> 16) & 0xFF,
                            g = (c >>  8) & 0xFF,
                            b = (c >>  0) & 0xFF;
                        
                        buf[y][4 * x + 0] = htons(r | (r << 8));
                        buf[y][4 * x + 1] = htons(g | (g << 8));
                        buf[y][4 * x + 2] = htons(b | (b << 8));
                        buf[y][4 * x + 3] = htons(0xffff);
		}
	}

	// Output farbfeld data.
	for (usize y = 0; y < height; ++y)
		fwrite(buf[y], sizeof(u16), width * 4, stdout);
}
