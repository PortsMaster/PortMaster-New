/*
 * stx2st - convert a Pasti .stx Atari ST disk image to a raw single-sided .st
 * (80 tracks x 9 sectors x 512 bytes) for the SunDog PortMaster port.
 *
 * Duplicate sector IDs on a track (SunDog's copy protection stores sector 5 of
 * track 3 twice) are resolved by keeping the later copy, which is the one that
 * matches the upstream sundog tools/compute_checksums.py reference values.
 *
 * usage: stx2st in.stx out.st
 * exit: 0 ok, 1 usage/IO error, 2 not an STX image or sectors missing
 *
 * MIT License, Copyright (c) 2026 Cebion
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TRACKS 80
#define SPT 9
#define SSIZE 512

static uint32_t le32(const unsigned char *p) { return p[0] | p[1] << 8 | p[2] << 16 | (uint32_t)p[3] << 24; }
static uint16_t le16(const unsigned char *p) { return p[0] | p[1] << 8; }

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "usage: %s in.stx out.st\n", argv[0]);
        return 1;
    }
    FILE *f = fopen(argv[1], "rb");
    if (!f) {
        perror(argv[1]);
        return 1;
    }
    fseek(f, 0, SEEK_END);
    long len = ftell(f);
    fseek(f, 0, SEEK_SET);
    unsigned char *d = malloc(len > 0 ? len : 1);
    if (!d || fread(d, 1, len, f) != (size_t)len) {
        fprintf(stderr, "%s: read failed\n", argv[1]);
        return 1;
    }
    fclose(f);
    if (len < 16 || memcmp(d, "RSY", 4) != 0) {
        fprintf(stderr, "%s: not a Pasti STX image\n", argv[1]);
        return 2;
    }

    static unsigned char out[TRACKS * SPT * SSIZE];
    static int filled[TRACKS][SPT + 1];
    int track_count = d[10];
    long pos = 16;

    for (int t = 0; t < track_count; t++) {
        if (pos + 16 > len) break;
        const unsigned char *h = d + pos;
        uint32_t rec_size = le32(h), fuzzy = le32(h + 4);
        uint16_t nsec = le16(h + 8), flags = le16(h + 10);
        int track = h[14] & 0x7f, side = h[14] >> 7;
        long p = pos + 16;
        if (rec_size < 16) break;

        if (!side && track < TRACKS) {
            if (flags & 0x01) {
                long area = p + 16L * nsec + fuzzy;
                for (int i = 0; i < nsec; i++) {
                    const unsigned char *s = d + p + 16L * i;
                    uint32_t off = le32(s);
                    int id_track = s[8], id_head = s[9], id_sector = s[10], size = 128 << (s[11] & 3), fdc = s[14];
                    if (id_track != track || id_head != 0 || size != SSIZE || id_sector < 1 || id_sector > SPT) continue;
                    if (fdc & 0x10) continue; /* record not found: no data stored */
                    if (area + off + SSIZE > len) continue;
                    memcpy(out + (track * SPT + id_sector - 1) * SSIZE, d + area + off, SSIZE);
                    filled[track][id_sector] = 1;
                }
            } else {
                for (int s = 1; s <= nsec && s <= SPT; s++) {
                    if (p + (long)s * SSIZE > len) break;
                    memcpy(out + (track * SPT + s - 1) * SSIZE, d + p + (long)(s - 1) * SSIZE, SSIZE);
                    filled[track][s] = 1;
                }
            }
        }
        pos += rec_size;
    }
    free(d);

    int missing = 0;
    for (int t = 0; t < TRACKS; t++)
        for (int s = 1; s <= SPT; s++)
            if (!filled[t][s]) missing++;
    if (missing) {
        fprintf(stderr, "%s: %d sectors missing, not a complete single-sided 9-sector disk\n", argv[1], missing);
        return 2;
    }

    f = fopen(argv[2], "wb");
    if (!f || fwrite(out, 1, sizeof(out), f) != sizeof(out) || fclose(f) != 0) {
        perror(argv[2]);
        return 1;
    }
    return 0;
}
