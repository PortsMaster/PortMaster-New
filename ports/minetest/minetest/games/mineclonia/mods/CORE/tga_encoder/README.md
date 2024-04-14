# tga_encoder
A TGA Encoder written in Lua without the use of external Libraries.

Created by fleckenstein for MineClone2, then improved by erlehmann.

May be used as a Minetest mod.

## Use Cases for `tga_encoder`

### Encoding Textures for Editing

TGA images of types 1/2/3 consist of header data followed by a pixel array.

This makes it trivial to parse TGA files – and even edit pixels in-place.

No checksums need to be updated on any kind of in-place texture editing.

**Tip**: When storing an editable image in item meta, use zlib compression.

### Legacy Minetest Texture Encoding

Minetest 5.4 did not include `minetest.encode_png()` (or any equvivalent).

Since `tga_encoder` is written in pure Lua, it does not need engine support.

### Advanced Texture Format Control

The function `minetest.encode_png()` always encodes images as 32bpp RGBA.

`tga_encoder` allows saving images as grayscale, 16bpp RGBA and 24bpp RGB.

For generating maps from terrain, color-mapped formats can be more useful.

### Encoding Very Small Textures

Images of size 8×8 or below are often smaller than an equivalent PNG file.

Note that on many filesystems files use at least 4096 bytes (i.e. 64×64).

Therefore, saving bytes on files up to a few 100 bytes is often useless.

### Encoding Reference Textures

TGA is a simple format, which makes it easy to create reference textures.

Using a hex editor, one can trivially see how all the pixels are stored.

## Supported Image Types

For all types, images are encoded in a fast single pass (i.e. append-only).

### Color-Mapped Images (Type 1)

These images contain a palette, followed by pixel data.

* `A1R5G5B5` (8bpp RGB)
* `B8G8R8` (8bpp RGB)
* `B8G8R8A8` (8bpp RGBA)

### True-Color Images (Type 2)

These images contain uncompressed RGB(A) pixel data.

* `A1R5G5B5` (16bpp RGBA)
* `B8G8R8` (24bpp RGB)
* `B8G8R8A8` (32bpp RGBA)

### Grayscale Images (Type 3)

* `Y8` (8bpp grayscale)

### Run-Length Encoded (RLE), True-Color Images (Type 10)

These images contain compressed RGB(A) pixel data.

* `A1R5G5B5` (16bpp RGBA)
* `B8G8R8` (24bpp RGB)
* `B8G8R8A8` (32bpp RGBA)
