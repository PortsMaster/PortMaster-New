using Microsoft.Xna.Framework;

namespace OrangeEngineR.Render
{
    // sheet.png/sheet2.png are shrunk 2x linearly by gfxpack.py, but
    // OeSheet.mRectangle keeps reporting each sprite's ORIGINAL (pre-shrink)
    // atlas position and size. A lot of game code (OeProp, the explosion /
    // death-effect systems, HookMan, the painting object, ...) reads
    // mRectangle.Width/Height directly for its own position or scale math,
    // entirely outside OeSheet's draw methods, and all of that keeps working
    // unmodified precisely because mRectangle never changes meaning.
    //
    // The only place the real (half-scale) numbers matter is the hand-off
    // from OeSheet to OeSpriteBatch. OeSpriteBatch's flush ends up in
    // SpriteBatch.Draw(tex, position + origin, srcRect, ..., origin, scale),
    // where srcRect and origin are in TEXTURE pixels and the drawn size is
    // srcRect.Size * scale. With a half-resolution texture, drawing exactly
    // what used to be drawn takes all four of these, applied together:
    //
    //   source rect  -> Halve   (where the sprite's pixels now live)
    //   scale        -> x2      (so size = (R/2) * (2S) = R * S, unchanged)
    //   origin       -> x0.5    (still the same point on the sprite)
    //   position     -> + O/2   (the flush anchors at position + origin; with
    //                            origin halved, position has to make up the
    //                            other half so position + origin is unchanged)
    //
    // EVERY OeSheet draw goes through those hand-offs, including sheets
    // built from standalone, unshrunk textures (whole-image backgrounds,
    // cutscene stills, tilesets, ...), so each helper takes an `atlas` flag
    // and is a no-op unless the sheet really lives in a shrunk atlas.
    public static class OeAtlasRectHelper
    {
        // The two atlases gfxpack.py shrinks. mUnderlyingTextureName is the
        // texture file name without extension, so atlas sprites (built from
        // sheet.txt / sheet2.txt entries) report "sheet" / "sheet2", while a
        // sheet built from its own image reports that image's name (or null).
        public static bool IsShrunkAtlas(string underlyingTextureName)
        {
            return underlyingTextureName == "sheet" || underlyingTextureName == "sheet2";
        }

        // Position uses plain integer /2 because gfxpack.py places every
        // sprite at an even (x, y) specifically so this is exact. Size uses
        // (n+1)/2 to match the ceiling division of the shrink pass itself -
        // a truncating /2 would read one pixel short on every odd-sized
        // sprite.
        public static Rectangle HalveIf(Rectangle r, bool atlas)
        {
            if (!atlas) return r;
            return new Rectangle(r.X / 2, r.Y / 2, (r.Width + 1) / 2, (r.Height + 1) / 2);
        }

        public static Vector2 DoubleIf(Vector2 v, bool atlas)
        {
            if (!atlas) return v;
            return new Vector2(v.X * 2f, v.Y * 2f);
        }

        // Scalar version of DoubleIf, for raw SpriteBatch.Draw call sites
        // that pass a float scale (OeRenderer's animated-tile draw).
        public static float DoubleIfF(float v, bool atlas)
        {
            return atlas ? v * 2f : v;
        }

        public static Vector2 HalveIfV2(Vector2 v, bool atlas)
        {
            if (!atlas) return v;
            return new Vector2(v.X * 0.5f, v.Y * 0.5f);
        }

        // `origin` here is the ORIGINAL (un-halved) origin the caller passed.
        public static Vector2 ShiftIf(Vector2 position, Vector2 origin, bool atlas)
        {
            if (!atlas) return position;
            return new Vector2(position.X + origin.X * 0.5f, position.Y + origin.Y * 0.5f);
        }
    }
}
