/*
 * zbinstall: lays out the Zoombinis port's game/ folder (C: and D:) from the
 * player's own disc: an image (.iso, a raw .bin, or a .cue naming one) or a
 * folder holding the disc's files.
 *
 *   zbinstall <disc.iso | disc.cue | disc.bin | folder> <game folder>
 *
 * Given a folder, it looks inside for a .cue, then an .iso or .bin, then the
 * disc's files (ZBARCHIV.Z, ZBARC32.Z or DATA1.HDR, there or one folder down).
 * Exits 3 if there's no disc at all, 1 if there is one but it can't be
 * installed from.
 *
 * D: gets the data folder's .MHK files, as DATA/ (DATA/ on the English CDs,
 * the language's folder on others, e.g. FRENCH/ on the 2002 French one; on a
 * disc with several, the one named in language.txt beside the disc); C: gets
 * what the installer would have written, as zbtools' `port.lay_out_drives` does:
 * ZOOMBI32/{mohawk.w32, Zoombini.who, MIDIMAP.DAT, ZOOMBI32.CFG},
 * WINDOWS/FONTS/CORNER.TTF and WINDOWS/TEMP/. Most of those are inside the CD's
 * installer archive:
 * - InstallShield 3 (ZBARCHIV.Z on version 1.0's CD, ZBARC32.Z on 1.1's, the
 *   "Deluxe" one), PKWARE DCL imploded: the reader and decompressor are a port
 *   of zbtools' src/zbtools/unpack_isz.py (itself a port of zlib's contrib/blast).
 * - An InstallShield 6+ cabinet (DATA1.HDR + DATA<n>.CAB, the French CD's),
 *   deflated in chunks: the reader follows unshield's lib/ (MIT). That CD holds
 *   the Windows 3.1 build, whose MOHAWK.WIN stands in for mohawk.w32 (the same
 *   sections the game reads).
 * - None on the 2001 rerelease (version 2.0): its font lies loose on the disc,
 *   its map is RODMAP.MHK and it has no MIDI music, so MIDIMPC.MHK is a
 *   placeholder and mohawk.w32 the settings the game reads.
 * The intro movie isn't converted (the port skips it without its .SCN).
 *
 * Writes into <game folder>.tmp and renames it at the end, so an interrupted
 * install leaves no game/ behind.
 */

#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <algorithm>
#include <filesystem>
#include <fstream>
#include <functional>
#include <map>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

#include <zlib.h>

namespace fs = std::filesystem;

static const char *const ARCHIVES[] = {
    "BASECAMP", "BCTWO", "BRIDGE", "CAVES", "FERRY",  "FLEENS",  "HOTEL",
    "LILLY",    "MAP",   "MAZE2",  "MIDIMPC", "NET",  "PICKER",  "PIZZA",
    "SLIDES",   "SMOKE", "TOWN",   "TUNNELS", "XFER", "ZOOMBINI",
};
/* The saved-game list's size (zbtools' formats/roster.py). */
static const size_t ROSTER_SIZE = 1606;
static const char CFG[] = "[INSTALL]\r\nINSTALLFROMDIR=D:\\\r\nINSTALLTODIR=C:\\ZOOMBI32\\\r\n";

static std::string upper(std::string text)
{
    for (char &c : text)
        c = (char)toupper((unsigned char)c);
    return text;
}

static uint32_t u16(const std::vector<uint8_t> &d, size_t at)
{
    if (at + 2 > d.size())
        throw std::runtime_error("truncated data");
    return d[at] | d[at + 1] << 8;
}

static uint32_t u32(const std::vector<uint8_t> &d, size_t at)
{
    return u16(d, at) | u16(d, at + 2) << 16;
}

/* --- The disc: its files by upper-case path ("DATA/ZOOMBINI.MHK"). -------- */

struct Disc
{
    /* Writes a file's bytes to `out` in pieces. */
    std::map<std::string, std::function<void(const std::function<void(const char *, size_t)> &)>> files;
    std::map<std::string, uint64_t> sizes;
    uint64_t lastSector = 0; /* (an image's: just past its last file's) */

    std::vector<uint8_t> read(const std::string &path)
    {
        std::vector<uint8_t> data;
        files.at(path)([&](const char *p, size_t n) { data.insert(data.end(), p, p + n); });
        return data;
    }
};

static void addFolder(Disc &disc, const fs::path &root)
{
    for (const auto &entry : fs::recursive_directory_iterator(root)) {
        if (!entry.is_regular_file())
            continue;
        std::string key = upper(fs::relative(entry.path(), root).generic_string());
        fs::path path = entry.path();
        disc.sizes[key] = entry.file_size();
        disc.files[key] = [path](const std::function<void(const char *, size_t)> &out) {
            std::ifstream in(path, std::ios::binary);
            std::vector<char> buffer(1 << 20);
            while (in) {
                in.read(buffer.data(), (std::streamsize)buffer.size());
                if (in.gcount() > 0)
                    out(buffer.data(), (size_t)in.gcount());
            }
        };
    }
}

/* ISO 9660, in 2048-byte sectors or raw 2352-byte ones (mode 1 or 2). */
struct Image
{
    std::shared_ptr<std::ifstream> in;
    uint64_t sectorSize = 2048, headerSize = 0;

    void readSector(uint32_t lba, char *to)
    {
        in->clear();
        in->seekg((std::streamoff)(lba * sectorSize + headerSize));
        in->read(to, 2048);
        if (in->gcount() != 2048)
            throw std::runtime_error("The disc image is cut short (an incomplete copy or download).");
    }
};

static void addDirectory(Disc &disc, Image image, uint32_t lba, uint32_t length, const std::string &prefix, int depth)
{
    if (depth > 16)
        return;
    std::vector<char> data(((length + 2047) / 2048) * 2048);
    for (uint32_t i = 0; i < data.size() / 2048; i++)
        image.readSector(lba + i, data.data() + i * 2048);
    for (size_t at = 0; at < length;) {
        uint8_t size = (uint8_t)data[at];
        if (size == 0) { /* records don't cross sectors */
            at = (at / 2048 + 1) * 2048;
            continue;
        }
        if (at + 33 > data.size() || at + size > data.size())
            break;
        const uint8_t *r = (const uint8_t *)data.data() + at;
        uint32_t extent = r[2] | r[3] << 8 | r[4] << 16 | (uint32_t)r[5] << 24;
        uint32_t bytes = r[10] | r[11] << 8 | r[12] << 16 | (uint32_t)r[13] << 24;
        bool directory = r[25] & 2;
        std::string name((const char *)r + 33, r[32]);
        at += size;
        if (name.size() == 1 && (name[0] == 0 || name[0] == 1))
            continue;
        name = name.substr(0, name.find(';'));
        if (!name.empty() && name.back() == '.')
            name.pop_back();
        std::string path = prefix + upper(name);
        if (directory)
            addDirectory(disc, image, extent, bytes, path + "/", depth + 1);
        else {
            disc.sizes[path] = bytes;
            disc.lastSector = std::max<uint64_t>(disc.lastSector, extent + (bytes + 2047) / 2048);
            disc.files[path] = [image, extent, bytes](const std::function<void(const char *, size_t)> &out) mutable {
                char sector[2048];
                for (uint32_t done = 0, i = 0; done < bytes; i++) {
                    image.readSector(extent + i, sector);
                    uint32_t n = std::min<uint32_t>(2048, bytes - done);
                    out(sector, n);
                    done += n;
                }
            };
        }
    }
}

static void addImage(Disc &disc, const fs::path &file)
{
    Image image;
    image.in = std::make_shared<std::ifstream>(file, std::ios::binary);
    if (!*image.in)
        throw std::runtime_error("cannot open " + file.string());
    const uint64_t layouts[][2] = {{2048, 0}, {2352, 16}, {2352, 24}};
    char pvd[2048];
    for (const auto &layout : layouts) {
        image.sectorSize = layout[0];
        image.headerSize = layout[1];
        try {
            image.readSector(16, pvd);
        } catch (const std::exception &) {
            continue;
        }
        if (pvd[0] == 1 && !memcmp(pvd + 1, "CD001", 5)) {
            const uint8_t *root = (const uint8_t *)pvd + 156;
            addDirectory(disc, image, root[2] | root[3] << 8 | root[4] << 16 | (uint32_t)root[5] << 24,
                         root[10] | root[11] << 8 | root[12] << 16 | (uint32_t)root[13] << 24, "", 0);
            /* A Mac/PC hybrid disc's ISO 9660 volume claims a few sectors (its HFS
               part spans the disc), and some ripping tools stop there. */
            uint64_t need = disc.lastSector * image.sectorSize;
            if (need > fs::file_size(file))
                throw std::runtime_error(file.filename().string() + " is cut short: it is " +
                                         std::to_string(fs::file_size(file) >> 10) + " KB, but its files run to " +
                                         std::to_string(need >> 20) + " MB. It was made by a tool that copied only the "
                                         "start of the disc: make a full copy of the CD.");
            return;
        }
    }
    throw std::runtime_error(file.filename().string() + " is not an ISO 9660 disc image");
}

/* The image a .cue sheet names: its first FILE (which, on a mixed-mode disc,
   is the data track). */
static fs::path cueImage(const fs::path &cue)
{
    std::ifstream in(cue);
    std::string line;
    while (std::getline(in, line)) {
        size_t at = line.find_first_not_of(" \t");
        if (at == std::string::npos || upper(line.substr(at, 5)) != "FILE ")
            continue;
        std::string rest = line.substr(at + 5);
        std::string name;
        if (!rest.empty() && rest[0] == '"')
            name = rest.substr(1, rest.find('"', 1) - 1);
        else
            name = rest.substr(0, rest.find(' '));
        fs::path image = cue.parent_path() / name;
        if (fs::is_regular_file(image))
            return image;
        /* (the sheet may name it in another case than the file has) */
        for (const auto &entry : fs::directory_iterator(cue.parent_path()))
            if (upper(entry.path().filename().string()) == upper(name))
                return entry.path();
        throw std::runtime_error(cue.filename().string() + " needs " + name + ", which isn't in gamedata. Copy it there too.");
    }
    throw std::runtime_error(cue.filename().string() + " names no image file");
}

/* What to install from, given a folder (else the path itself); empty if none. */
static fs::path findDisc(const fs::path &source)
{
    if (!fs::is_directory(source))
        return fs::exists(source) ? source : fs::path();
    std::vector<fs::path> files;
    for (const auto &entry : fs::directory_iterator(source))
        if (entry.is_regular_file())
            files.push_back(entry.path());
    std::sort(files.begin(), files.end());
    for (const char *extension : {".CUE", ".ISO", ".BIN"})
        for (const fs::path &file : files)
            if (upper(file.extension().string()) == extension)
                return file;
    std::vector<fs::path> folders{source};
    for (const auto &entry : fs::directory_iterator(source))
        if (entry.is_directory())
            folders.push_back(entry.path());
    for (const fs::path &folder : folders)
        for (const auto &entry : fs::directory_iterator(folder))
            for (const char *marker : {"ZBARCHIV.Z", "ZBARC32.Z", "DATA1.HDR"})
                if (upper(entry.path().filename().string()) == marker
                    || (entry.is_directory() && upper(entry.path().filename().string()) == "DATA"
                        && (fs::exists(entry.path() / "ZOOMBINI.MHK") || fs::exists(entry.path() / "Zoombini.MHK"))))
                    return folder;
    return fs::path();
}

/* --- PKWARE DCL explode (zlib's contrib/blast) ----------------------------- */

static const uint8_t LITLEN[] = {
    11, 124, 8, 7, 28, 7, 188, 13, 76, 4, 10, 8, 12, 10, 12, 10, 8, 23, 8,
    9, 7, 6, 7, 8, 7, 6, 55, 8, 23, 24, 12, 11, 7, 9, 11, 12, 6, 7, 22, 5,
    7, 24, 6, 11, 9, 6, 7, 22, 7, 11, 38, 7, 9, 8, 25, 11, 8, 11, 9, 12,
    8, 12, 5, 38, 5, 38, 5, 11, 7, 5, 6, 21, 6, 10, 53, 8, 7, 24, 10, 27,
    44, 253, 253, 253, 252, 252, 252, 13, 12, 45, 12, 45, 12, 61, 12, 45,
    44, 173};
static const uint8_t LENLEN[] = {2, 35, 36, 53, 38, 23};
static const uint8_t DISTLEN[] = {2, 20, 53, 230, 247, 151, 248};
static const int LEN_BASE[] = {3, 2, 4, 5, 6, 7, 8, 9, 10, 12, 16, 24, 40, 72, 136, 264};
static const int LEN_EXTRA[] = {0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8};
static const int MAXBITS = 13;

struct Huffman
{
    std::vector<int> counts, symbols;

    Huffman(const uint8_t *rep, size_t size) : counts(MAXBITS + 1)
    {
        std::vector<int> lengths;
        for (size_t i = 0; i < size; i++)
            lengths.insert(lengths.end(), (rep[i] >> 4) + 1, rep[i] & 15);
        for (int n : lengths)
            counts[n]++;
        std::vector<int> offs(MAXBITS + 1);
        for (int n = 1; n < MAXBITS; n++)
            offs[n + 1] = offs[n] + counts[n];
        symbols.resize(lengths.size());
        for (size_t sym = 0; sym < lengths.size(); sym++)
            if (lengths[sym])
                symbols[offs[lengths[sym]]++] = (int)sym;
    }
};

struct BitReader
{
    const uint8_t *data;
    size_t size, pos = 0;
    uint32_t buf = 0;
    int cnt = 0;

    int bits(int need)
    {
        while (cnt < need) {
            if (pos >= size)
                throw std::runtime_error("unexpected end of compressed data");
            buf |= (uint32_t)data[pos++] << cnt;
            cnt += 8;
        }
        int value = (int)(buf & ((1u << need) - 1));
        buf >>= need;
        cnt -= need;
        return value;
    }

    int decode(const Huffman &table)
    {
        int code = 0, first = 0, index = 0;
        for (int n = 1; n <= MAXBITS; n++) {
            code |= bits(1) ^ 1; /* codes are stored bit-inverted */
            if (code < first + table.counts[n])
                return table.symbols[index + code - first];
            index += table.counts[n];
            first = (first + table.counts[n]) << 1;
            code <<= 1;
        }
        throw std::runtime_error("invalid Huffman code");
    }
};

static std::vector<uint8_t> explode(const uint8_t *data, size_t size)
{
    static const Huffman litcode(LITLEN, sizeof LITLEN), lencode(LENLEN, sizeof LENLEN),
        distcode(DISTLEN, sizeof DISTLEN);
    BitReader s{data, size};
    int lit = s.bits(8), dictBits = s.bits(8);
    if (lit > 1 || dictBits < 4 || dictBits > 6)
        throw std::runtime_error("bad DCL header");
    std::vector<uint8_t> out;
    for (;;) {
        if (s.bits(1)) {
            int sym = s.decode(lencode);
            int length = LEN_BASE[sym] + s.bits(LEN_EXTRA[sym]);
            if (length == 519) /* end of stream */
                break;
            int shift = length == 2 ? 2 : dictBits;
            size_t dist = ((size_t)s.decode(distcode) << shift) + s.bits(shift) + 1;
            if (dist > out.size())
                throw std::runtime_error("distance too far back");
            size_t start = out.size() - dist;
            for (int i = 0; i < length; i++)
                out.push_back(out[start + i]);
        } else
            out.push_back((uint8_t)(lit ? s.decode(litcode) : s.bits(8)));
    }
    return out;
}

/* --- InstallShield 3 archive: its files by upper-case base name. ----------- */

static std::map<std::string, std::vector<uint8_t>> unpackArchive(const std::vector<uint8_t> &data,
                                                                  const std::vector<std::string> &wanted)
{
    if (u32(data, 0) != 0x8C655D13)
        throw std::runtime_error("not an InstallShield 3 archive");
    uint32_t fileCount = u16(data, 0x0C), toc = u32(data, 0x29), dirCount = u16(data, 0x31);
    size_t pos = toc;
    for (uint32_t i = 0; i < dirCount; i++)
        pos += u16(data, pos + 2);
    std::map<std::string, std::vector<uint8_t>> found;
    for (uint32_t i = 0; i < fileCount; i++) {
        if (pos + 0x1E > data.size())
            throw std::runtime_error("the archive's table of contents is truncated");
        uint8_t nameLength = data[pos + 0x1D];
        std::string name = upper(std::string((const char *)data.data() + pos + 0x1E, nameLength));
        uint32_t size = u32(data, pos + 0x03), packed = u32(data, pos + 0x07), offset = u32(data, pos + 0x0B);
        if (std::find(wanted.begin(), wanted.end(), name) != wanted.end() && !found.count(name)) {
            if ((uint64_t)offset + packed > data.size())
                throw std::runtime_error(name + " runs past the end of the archive");
            std::vector<uint8_t> raw = explode(data.data() + offset, packed);
            if (raw.size() != size)
                throw std::runtime_error(name + " in the archive has the wrong size");
            found[name] = std::move(raw);
        }
        pos += u16(data, pos + 0x17);
    }
    return found;
}

/* --- InstallShield 6+ cabinet: its files by upper-case base name. ---------- */

static uint64_t u64(const std::vector<uint8_t> &d, size_t at)
{
    return u32(d, at) | (uint64_t)u32(d, at + 4) << 32;
}

/* One deflated chunk (raw deflate, ending in a sync flush) onto `out`. */
static void inflateChunk(const uint8_t *data, size_t size, std::vector<uint8_t> &out)
{
    z_stream stream = {};
    if (inflateInit2(&stream, -MAX_WBITS) != Z_OK)
        throw std::runtime_error("inflateInit2 failed");
    stream.next_in = (Bytef *)data;
    stream.avail_in = (uInt)size;
    uint8_t buffer[65536];
    int result;
    do {
        stream.next_out = buffer;
        stream.avail_out = sizeof buffer;
        result = inflate(&stream, Z_SYNC_FLUSH);
        out.insert(out.end(), buffer, buffer + (sizeof buffer - stream.avail_out));
    } while (result == Z_OK && (stream.avail_in || !stream.avail_out));
    inflateEnd(&stream);
    if (result != Z_OK && result != Z_STREAM_END && result != Z_BUF_ERROR)
        throw std::runtime_error("a compressed file in the cabinet is damaged");
}

/* `header` is the cabinet's DATA1.HDR (upper-case disc path), or on an
   InstallShield 5 one its DATA1.CAB, which holds the header itself; the
   volumes are DATA<n>.CAB beside it. */
static std::map<std::string, std::vector<uint8_t>> unpackCabinet(Disc &disc, const std::string &header,
                                                                 const std::vector<std::string> &wanted)
{
    std::vector<uint8_t> hdr = disc.read(header);
    if (u32(hdr, 0) != 0x28635349)
        throw std::runtime_error(header + " is not an InstallShield cabinet");
    uint32_t version = u32(hdr, 4), major = 0;
    if (version >> 24 == 1)
        major = (version >> 12) & 0xf;
    else if (version >> 24 == 2 || version >> 24 == 4)
        major = (version & 0xffff) / 100;
    size_t descriptor = u32(hdr, 0x0C);
    size_t fileTable = descriptor + u32(hdr, descriptor + 0x0C);
    uint32_t directoryCount = u32(hdr, descriptor + 0x1C), fileCount = u32(hdr, descriptor + 0x28);
    size_t descriptors = fileTable + u32(hdr, descriptor + 0x2C);
    std::string base = header.substr(0, header.size() - strlen("1.HDR"));

    std::map<std::string, std::vector<uint8_t>> found;
    std::map<uint32_t, std::vector<uint8_t>> volumes;
    for (uint32_t i = 0; i < fileCount; i++) {
        uint32_t flags, volume;
        uint64_t expanded, compressed, offset;
        size_t nameAt;
        if (major >= 6) {
            size_t fd = descriptors + (size_t)i * 0x57;
            flags = u16(hdr, fd);
            expanded = u64(hdr, fd + 0x02), compressed = u64(hdr, fd + 0x0A), offset = u64(hdr, fd + 0x12);
            nameAt = fileTable + u32(hdr, fd + 0x3A);
            volume = u16(hdr, fd + 0x55);
        } else { /* InstallShield 5 and older: a table of offsets, files in volume 1 */
            size_t fd = fileTable + u32(hdr, fileTable + (directoryCount + i) * 4);
            nameAt = fileTable + u32(hdr, fd);
            flags = u16(hdr, fd + 0x08);
            expanded = u32(hdr, fd + 0x0A), compressed = u32(hdr, fd + 0x0E), offset = u32(hdr, fd + 0x26);
            volume = 1;
        }
        if (nameAt >= hdr.size() || (flags & 8) || !offset)
            continue;
        std::string name = upper(std::string((const char *)hdr.data() + nameAt,
                                             strnlen((const char *)hdr.data() + nameAt, hdr.size() - nameAt)));
        if (std::find(wanted.begin(), wanted.end(), name) == wanted.end() || found.count(name))
            continue;
        if (flags & 1)
            throw std::runtime_error(name + " is split across the cabinet's volumes, which isn't supported");
        std::string cab = base + std::to_string(volume) + ".CAB";
        if (!disc.files.count(cab))
            throw std::runtime_error("the disc has no " + cab);
        if (!volumes.count(volume))
            volumes[volume] = disc.read(cab);
        const std::vector<uint8_t> &data = volumes[volume];
        uint64_t stored = (flags & 4) ? compressed : expanded;
        if (offset + stored > data.size())
            throw std::runtime_error(name + " runs past the end of " + cab);
        std::vector<uint8_t> raw(data.begin() + (ptrdiff_t)offset, data.begin() + (ptrdiff_t)(offset + stored));
        if (flags & 2) /* obfuscated */
            for (size_t n = 0; n < raw.size(); n++) {
                uint8_t b = raw[n] ^ 0xd5;
                raw[n] = (uint8_t)(((b >> 2) | (b << 6)) - (n % 0x47));
            }
        std::vector<uint8_t> out;
        if (flags & 4) {
            /* Deflated in chunks, each after its size; else (older cabinets) one
               stream of chunks ending in sync flushes. */
            try {
                for (size_t at = 0; at + 2 <= raw.size();) {
                    size_t chunk = raw[at] | raw[at + 1] << 8;
                    at += 2;
                    if (!chunk || at + chunk > raw.size())
                        throw std::runtime_error("bad chunk");
                    inflateChunk(raw.data() + at, chunk, out);
                    at += chunk;
                }
            } catch (const std::exception &) {
                out.clear();
            }
            if (out.size() != expanded) {
                out.clear();
                inflateChunk(raw.data(), raw.size(), out);
            }
        } else
            out = std::move(raw);
        if (out.size() != expanded)
            throw std::runtime_error(name + " in the cabinet is damaged");
        found[name] = std::move(out);
    }
    return found;
}

/* --- The install ------------------------------------------------------------ */

static void writeFile(const fs::path &path, const void *data, size_t size)
{
    fs::create_directories(path.parent_path());
    std::ofstream out(path, std::ios::binary);
    out.write((const char *)data, (std::streamsize)size);
    if (!out)
        throw std::runtime_error("Cannot write " + path.string() + ". Is there enough free space?");
}

static void copyFile(Disc &disc, const std::string &key, const fs::path &to)
{
    fs::create_directories(to.parent_path());
    std::ofstream out(to, std::ios::binary);
    uint64_t written = 0;
    disc.files.at(key)([&](const char *p, size_t n) {
        out.write(p, (std::streamsize)n);
        written += n;
    });
    if (!out || written != disc.sizes.at(key))
        throw std::runtime_error("Cannot copy " + key + " from the disc. Is there enough free space?");
}

static void install(Disc &disc, const fs::path &game, const std::string &language)
{
    /* The archives' folder: DATA on the English CDs, the language's on others;
       a disc with several (ENGLISH, FRENCH, GERMAN) takes `language`'s, else
       the first. */
    std::vector<std::string> languages;
    for (const auto &file : disc.files) {
        size_t slash = file.first.find('/');
        if (slash != std::string::npos && file.first.substr(slash) == "/ZOOMBINI.MHK")
            languages.push_back(file.first.substr(0, slash));
    }
    if (languages.size() > 1) {
        std::string list;
        for (const std::string &name : languages)
            list += (list.empty() ? "" : ", ") + name;
        printf("languages on the disc: %s\n", list.c_str());
    }
    std::string data = "DATA/";
    if (!language.empty() && std::find(languages.begin(), languages.end(), language) != languages.end())
        data = language + "/";
    else {
        if (!language.empty())
            printf("no %s on the disc, ignoring language.txt\n", language.c_str());
        if (!disc.files.count(data + "ZOOMBINI.MHK") && !languages.empty())
            data = languages.front() + "/";
    }
    printf("installing %s\n", data.c_str());
    /* Version 1.0's CD has ZBARCHIV.Z and MIDIMAP.DAT at its root; 1.1's ("Deluxe")
       has ZBARC32.Z, with MIDIMAP.DAT inside it and no saved-game list; the
       French CD has an InstallShield 6 cabinet. */
    std::string archive;
    for (const char *name : {"ZBARCHIV.Z", "ZBARC32.Z"})
        if (archive.empty() && disc.files.count(name))
            archive = name;
    /* InstallShield 5+ cabinets: DATA1.HDR, or DATA1.CAB alone (holding its
       header), at the root (the French CD) or in a folder (SETUP/ on the Korean). */
    std::vector<std::string> cabinets;
    for (const auto &file : disc.files) {
        const std::string &key = file.first;
        size_t slash = key.rfind('/');
        std::string name = key.substr(slash == std::string::npos ? 0 : slash + 1);
        std::string folder = key.substr(0, key.size() - name.size());
        if (name == "DATA1.HDR" || (name == "DATA1.CAB" && !disc.files.count(folder + "DATA1.HDR")))
            cabinets.push_back(key);
    }
    std::stable_sort(cabinets.begin(), cabinets.end(), [](const std::string &a, const std::string &b) {
        return std::count(a.begin(), a.end(), '/') < std::count(b.begin(), b.end(), '/');
    });
    /* The 2001 rerelease (version 2.0) has no installer archive (its C: files lie
       loose, e.g. INSTALL/HD/CORNER.TTF), keeps the map in RODMAP.MHK and has no
       MIDI music (MIDIMPC.MHK). */
    std::vector<std::string> missing;
    for (const char *name : ARCHIVES)
        if (!disc.files.count(data + name + ".MHK") && strcmp(name, "MIDIMPC")
            && !(!strcmp(name, "MAP") && disc.files.count(data + "RODMAP.MHK")))
            missing.push_back(data + name + ".MHK");
    if (!missing.empty()) {
        std::string list;
        for (const std::string &name : missing)
            list += (list.empty() ? "" : ", ") + name;
        throw std::runtime_error("This isn't a Zoombinis disc, or the copy is incomplete. Missing: " + list);
    }

    const std::vector<std::string> wanted{"MOHAWK.W32", "MOHAWK.WIN", "CORNER.TTF", "ZOOMBINI.WHO", "MIDIMAP.DAT"};
    std::map<std::string, std::vector<uint8_t>> installed;
    std::string problem; /* (a cabinet's, reported if nothing else has the font) */
    if (!archive.empty())
        installed = unpackArchive(disc.read(archive), wanted);
    for (const std::string &cabinet : cabinets)
        if (!installed.count("CORNER.TTF"))
            try {
                for (auto &file : unpackCabinet(disc, cabinet, wanted))
                    if (!installed.count(file.first))
                        installed[file.first] = std::move(file.second);
                if (archive.empty())
                    archive = cabinet;
            } catch (const std::exception &error) {
                problem = error.what();
            }
    for (const std::string &name : wanted) /* (loose on the disc: the root's first) */
        for (const auto &file : disc.sizes)
            if (!installed.count(name) && (file.first == name || (file.first.size() > name.size()
                    && file.first.compare(file.first.size() - name.size() - 1, std::string::npos, "/" + name) == 0)))
                installed[name] = disc.read(file.first);
    if (disc.files.count("MIDIMAP.DAT"))
        installed["MIDIMAP.DAT"] = disc.read("MIDIMAP.DAT");
    if (!installed.count("MOHAWK.W32") && installed.count("MOHAWK.WIN"))
        installed["MOHAWK.W32"] = installed["MOHAWK.WIN"];
    if (!installed.count("MOHAWK.W32")) {
        /* The settings the game reads: its MIDI map for a General MIDI port. */
        static const char settings[] = "[WaveMix]\r\nfEnable = false\r\n\r\n"
                                       "[MidiMap.TargetDevices]\r\nunknown device (port) = -4\r\n\r\n"
                                       "[MidiMap.TargetDeviceInfo]\r\n-4 = 01234XX789ABCDEX;10;1;1\r\n";
        installed["MOHAWK.W32"].assign(settings, settings + sizeof settings - 1);
    }
    if (!installed.count("CORNER.TTF"))
        throw std::runtime_error("The game's font, CORNER.TTF, isn't on the disc or in its installer"
                                 + (problem.empty() ? std::string() : " (" + problem + ")"));
    if (!installed.count("ZOOMBINI.WHO")) {
        /* An empty list: the format's version (107), no games. */
        installed["ZOOMBINI.WHO"].assign(ROSTER_SIZE, 0);
        installed["ZOOMBINI.WHO"][0] = 107;
    }

    fs::path tmp = game;
    tmp += ".tmp";
    fs::remove_all(tmp);
    /* (every .MHK, with the ones a later CD added beside the game's 20) */
    for (const auto &file : disc.sizes) {
        const std::string &key = file.first;
        if (key.compare(0, data.size(), data) || key.find('/', data.size()) != std::string::npos
            || key.size() < 4 || key.substr(key.size() - 4) != ".MHK")
            continue;
        printf("%s\n", key.c_str());
        fflush(stdout);
        fs::path to = tmp / "D" / "DATA" / key.substr(data.size());
        copyFile(disc, key, to);
        char magic[4] = {};
        std::ifstream(to, std::ios::binary).read(magic, 4);
        if (memcmp(magic, "MHWK", 4))
            throw std::runtime_error(key + " is not a Mohawk archive");
    }
    fs::path d = tmp / "D" / "DATA";
    if (!disc.files.count(data + "MAP.MHK"))
        copyFile(disc, data + "RODMAP.MHK", d / "MAP.MHK");
    if (!disc.files.count(data + "MIDIMPC.MHK")) {
        /* No music: an archive the game can open, holding one placeholder
           resource ('NONE' 1, written by zbtools' mohawk.write). */
        static const uint8_t noMusic[] = {
            0x4d, 0x48, 0x57, 0x4b, 0x00, 0x00, 0x00, 0x42, 0x52, 0x53, 0x52, 0x43, 0x01, 0x00, 0x00, 0x01,
            0x00, 0x00, 0x00, 0x4a, 0x00, 0x00, 0x00, 0x28, 0x00, 0x14, 0x00, 0x0e, 0x00, 0x04, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x14, 0x00, 0x01, 0x4e, 0x4f, 0x4e, 0x45,
            0x00, 0x0c, 0x00, 0x12, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
            0x00, 0x00, 0x00, 0x24, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00};
        writeFile(d / "MIDIMPC.MHK", noMusic, sizeof noMusic);
    }
    fs::path c = tmp / "C", target = c / "ZOOMBI32";
    if (installed.count("MIDIMAP.DAT"))
        writeFile(target / "MIDIMAP.DAT", installed["MIDIMAP.DAT"].data(), installed["MIDIMAP.DAT"].size());
    writeFile(target / "mohawk.w32", installed["MOHAWK.W32"].data(), installed["MOHAWK.W32"].size());
    writeFile(target / "Zoombini.who", installed["ZOOMBINI.WHO"].data(), installed["ZOOMBINI.WHO"].size());
    writeFile(target / "ZOOMBI32.CFG", CFG, sizeof CFG - 1);
    writeFile(c / "WINDOWS" / "FONTS" / "CORNER.TTF", installed["CORNER.TTF"].data(), installed["CORNER.TTF"].size());
    fs::create_directories(c / "WINDOWS" / "TEMP");
    fs::remove_all(game);
    fs::rename(tmp, game);
}

int main(int argc, char **argv)
{
    if (argc != 3) {
        fprintf(stderr, "usage: zbinstall <disc.iso | disc.cue | disc.bin | folder> <game folder>\n");
        return 2;
    }
    try {
        Disc disc;
        fs::path source = findDisc(argv[1]);
        if (source.empty()) {
            fprintf(stderr, "zbinstall: no disc in %s\n", argv[1]);
            return 3;
        }
        printf("installing from %s\n", source.string().c_str());
        if (fs::is_directory(source))
            addFolder(disc, source);
        else if (upper(source.extension().string()) == ".CUE")
            addImage(disc, cueImage(source));
        else
            addImage(disc, source);
        /* (the player's choice on a disc with several languages: language.txt
           beside the disc, e.g. "german") */
        std::string language;
        fs::path choice = (fs::is_directory(argv[1]) ? fs::path(argv[1]) : fs::path(argv[1]).parent_path()) / "language.txt";
        if (fs::is_regular_file(choice)) {
            std::ifstream in(choice);
            std::getline(in, language);
            language = upper(language);
            language.erase(0, language.find_first_not_of(" \t\r\xEF\xBB\xBF"));
            language.erase(language.find_last_not_of(" \t\r") + 1);
        }
        install(disc, argv[2], language);
    } catch (const std::exception &error) {
        fprintf(stderr, "zbinstall: %s\n", error.what());
        return 1;
    }
    printf("installed into %s\n", argv[2]);
    return 0;
}
