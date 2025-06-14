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

	usize pxw  = argc > 5 ? strtol(argv[5], NULL, 0) : 1;

	// Output farbfeld headers.
	u32 tmp;
	fputs("farbfeld", stdout);
	tmp = htonl(width * pxw);
	fwrite(&tmp, sizeof(tmp), 1, stdout);
	tmp = htonl(height * pxw);
	fwrite(&tmp, sizeof(tmp), 1, stdout);

#define SET(X) do { \
        buf[4 * (X) + 0] = htons(r | (r << 8)); \
        buf[4 * (X) + 1] = htons(g | (g << 8)); \
        buf[4 * (X) + 2] = htons(b | (b << 8)); \
        buf[4 * (X) + 3] = htons(0xffff);       \
} while (0);

	u16 *buf = malloc(4 * width * pxw * sizeof(u16));

	for (usize y = 0; y < (height*pxw); y += pxw) {
		for (usize x = 0; x < (width*pxw); x += pxw) {
			u32 c = getchar() == '0' ? bg : fg,
                            r = (c >> 16) & 0xFF,
                            g = (c >>  8) & 0xFF,
                            b = (c >>  0) & 0xFF;

			for (usize px = 0; px < pxw; ++px)
				SET(x + px);
		}

		for (usize py = 0; py < pxw; ++py) {
			fwrite(buf, sizeof(u16), width * pxw * 4, stdout);
		}
	}

	free(buf);
}
