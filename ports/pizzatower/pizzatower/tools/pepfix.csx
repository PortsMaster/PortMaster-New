// Fixes yellow Peppino/Gustavo: ASTC breaks the exact colour match shd_pal_swapper needs.
// Moves spr_peppalette + spr_ratmountpalette to a small page that stays uncompressed, lets the two
// shirt rows of those palettes match within SHIRT_TOL, and writes keep_textures.txt for `dump -k`.
using System.IO;
using System.Linq;

const string SHIRT_TOL = "0.04";
const string MARKER = "pepfix";
const int SIZE = 32;

var group = Data.TextureGroupInfo.First(g => g.Name.Content == "playergroup");
var items = new[] { "spr_peppalette", "spr_ratmountpalette" }.Select(n => Data.Sprites.ByName(n).Textures[0].Texture).ToArray();
var page = items[0].TexturePage;

if (page.TextureData.Image.Width != SIZE)
{
    var px = new byte[SIZE * SIZE * 4];
    int y0 = 0;
    foreach (var it in items)
    {
        var src = it.TexturePage.TextureData.Image.ConvertToFormat(GMImage.ImageFormat.RawBgra);
        byte[] sp = src.ToSpan().ToArray();
        for (int y = 0; y < it.SourceHeight; y++)
            Array.Copy(sp, ((it.SourceY + y) * src.Width + it.SourceX) * 4, px, (y0 + y) * SIZE * 4, it.SourceWidth * 4);
        it.SourceX = 0;
        it.SourceY = (ushort)y0;
        y0 += it.SourceHeight + 2;
    }

    page = new UndertaleEmbeddedTexture();
    page.Name = new UndertaleString($"Texture {Data.EmbeddedTextures.Count}");
    page.Scaled = items[0].TexturePage.Scaled;
    page.TextureWidth = SIZE;
    page.TextureHeight = SIZE;
    page.IndexInGroup = group.TexturePages.Count;
    page.TextureData.Image = new GMImage(GMImage.ImageFormat.RawBgra, SIZE, SIZE, px).ConvertToPng();
    Data.EmbeddedTextures.Add(page);
    group.TexturePages.Add(new UndertaleResourceById<UndertaleEmbeddedTexture, UndertaleChunkTXTR>() { Resource = page });
    foreach (var it in items)
        it.TexturePage = page;
}

var shader = Data.Shaders.ByName("shd_pal_swapper");
string frag = shader.GLSL_ES_Fragment.Content;
if (!frag.Contains(MARKER))
{
    const string match = "if (distance(source, texture2D(palette_texture, vec2(palette_UVs.x, i))) <= 0.004) {";
    if (!frag.Contains(match))
        throw new ScriptException("pepfix: unexpected shd_pal_swapper source");

    // Only the Peppino/Gustavo palettes start with exactly black, FFFF40, 918F2B
    frag = frag.Replace("void main()",
        "// " + MARKER + ": shirt rows of the Peppino/Gustavo palettes tolerate ASTC error\n" +
        "bool pm_is_pep_palette()\n{\n" +
        "\tif (palette_UVs.w - palette_UVs.y < 5.5 * texel_size.y) return false;\n" +
        "\tvec4 r0 = texture2D(palette_texture, vec2(palette_UVs.x, palette_UVs.y));\n" +
        "\tvec4 r1 = texture2D(palette_texture, vec2(palette_UVs.x, palette_UVs.y + texel_size.y));\n" +
        "\tvec4 r2 = texture2D(palette_texture, vec2(palette_UVs.x, palette_UVs.y + 2.0 * texel_size.y));\n" +
        "\treturn distance(r0, vec4(0.0, 0.0, 0.0, 1.0)) < 0.003\n" +
        "\t\t&& distance(r1, vec4(1.0, 1.0, 64.0 / 255.0, 1.0)) < 0.003\n" +
        "\t\t&& distance(r2, vec4(145.0 / 255.0, 143.0 / 255.0, 43.0 / 255.0, 1.0)) < 0.003;\n}\n\n" +
        "void main()");
    frag = frag.Replace("DoAlphaTest( source );", "DoAlphaTest( source );\n\tbool pm_pep = pm_is_pep_palette();");
    frag = frag.Replace(match,
        "float pm_row = floor((i - palette_UVs.y) / texel_size.y + 0.5);\n" +
        "\t\tfloat pm_tol = (pm_pep && pm_row > 0.5 && pm_row < 2.5) ? " + SHIRT_TOL + " : 0.004;\n" +
        "\t\tif (distance(source, texture2D(palette_texture, vec2(palette_UVs.x, i))) <= pm_tol) {");
    shader.GLSL_ES_Fragment = Data.Strings.MakeString(frag);
}

File.WriteAllText(Path.Combine(Path.GetDirectoryName(FilePath), "keep_textures.txt"), $"{Data.EmbeddedTextures.IndexOf(page)}\n");
