using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using UndertaleModLib.Util;
using ImageMagick;

string importFolder = Environment.GetEnvironmentVariable("UMT_SPRITES_FOLDER");
string paddedStr = Environment.GetEnvironmentVariable("UMT_PADDED");

if (string.IsNullOrEmpty(importFolder) || string.IsNullOrEmpty(paddedStr))
{
    Console.WriteLine("Error: Required environment variables not set.");
    Console.WriteLine("Usage: Set UMT_SPRITES_FOLDER and UMT_PADDED.");
    Console.WriteLine("Example: UMT_SPRITES_FOLDER=/path/to/sprites UMT_PADDED=true");
    return;
}

bool padded;
if (!bool.TryParse(paddedStr, out padded))
{
    Console.WriteLine("Error: UMT_PADDED must be 'true' or 'false'");
    return;
}

EnsureDataLoaded();

static List<MagickImage> imagesToCleanup = new();
bool importAsSprite = true; // Force import as sprites since we're specifying sprite names
Regex sprFrameRegex = new(@"^(.+?)(?:_(\d+))$", RegexOptions.Compiled);
bool noMasksForBasicRectangles = Data.IsVersionAtLeast(2022, 9);
bool bboxMasks = Data.IsVersionAtLeast(2024, 6);

try
{
    // Collect all sprite names from .png files
    var spriteFiles = Directory.GetFiles(importFolder, "*.png", SearchOption.AllDirectories)
        .Select(Path.GetFileNameWithoutExtension)
        .Select(x => sprFrameRegex.Match(x))
        .Where(m => m.Success || !m.Success) // Include both framed and non-framed files
        .Select(m => m.Success ? m.Groups[1].Value : m.Value)
        .Distinct(StringComparer.InvariantCultureIgnoreCase)
        .ToArray();

    if (spriteFiles.Length == 0)
    {
        Console.WriteLine("Error: No .png files found in the specified folder.");
        return;
    }

    // Validate sprite frames
    foreach (string spriteName in spriteFiles)
    {
        string[][] spriteFrames = Directory.GetFiles(importFolder, $"{spriteName}_*.png", SearchOption.AllDirectories)
            .Select(x =>
            {
                var match = sprFrameRegex.Match(Path.GetFileNameWithoutExtension(x));
                if (match.Success)
                    return new string[] { match.Groups[1].Value, match.Groups[2].Value };
                return null;
            })
            .OfType<string[]>().ToArray();

        if (spriteFrames.Length == 0)
        {
            // Handle single-frame sprites (no _0, _1, etc.)
            if (Directory.GetFiles(importFolder, $"{spriteName}.png", SearchOption.AllDirectories).Length > 0)
            {
                Console.WriteLine($"Found single-frame sprite: {spriteName}");
                continue;
            }
            Console.WriteLine($"Warning: No frames found for sprite {spriteName}. Skipping...");
            continue;
        }

        int[] frameIndexes = spriteFrames.Select(x =>
        {
            if (Int32.TryParse(x[1], out int frame))
                return (int?)frame;
            return null;
        }).OfType<int?>().Cast<int>().OrderBy(x => x).ToArray();

        if (frameIndexes.Length > 1)
        {
            for (int i = 0; i < frameIndexes.Length - 1; i++)
            {
                int num = frameIndexes[i];
                int nextNum = frameIndexes[i + 1];
                if (nextNum - num > 1)
                {
                    Console.WriteLine($"Error: Sprite {spriteName} is missing frame index {num + 1}.");
                    return;
                }
            }
        }
    }

    string packDir = Path.Combine(Path.GetDirectoryName(importFolder), "Packager");
    Directory.CreateDirectory(packDir);

    string sourcePath = importFolder;
    string searchPattern = "*.png";
    string outName = Path.Combine(packDir, "atlas.txt");
    int textureSize = 2048;
    int paddingValue = padded ? 2 : 0;
    bool debug = false;
    Packer packer = new Packer();
    packer.Process(sourcePath, searchPattern, textureSize, paddingValue, debug);
    packer.SaveAtlasses(outName);

    int lastTextPage = Data.EmbeddedTextures.Count - 1;
    int lastTextPageItem = Data.TexturePageItems.Count - 1;

    Dictionary<UndertaleSprite, Node> maskNodes = new();

    string prefix = outName.Replace(Path.GetExtension(outName), "");
    int atlasCount = 0;
    foreach (Atlas atlas in packer.Atlasses)
    {
        string atlasName = Path.Combine(packDir, $"{prefix}{atlasCount:000}.png");
        using MagickImage atlasImage = TextureWorker.ReadBGRAImageFromFile(atlasName);
        IPixelCollection<byte> atlasPixels = atlasImage.GetPixels();

        UndertaleEmbeddedTexture texture = new();
        texture.Name = new UndertaleString($"Texture {++lastTextPage}");
        texture.TextureData.Image = GMImage.FromMagickImage(atlasImage).ConvertToPng();
        Data.EmbeddedTextures.Add(texture);

        foreach (Node n in atlas.Nodes)
        {
            if (n.Texture != null)
            {
                string stripped = Path.GetFileNameWithoutExtension(n.Texture.Source);
                string spriteName;
                int frame = 0;
                var spriteParts = sprFrameRegex.Match(stripped);
                if (spriteParts.Success)
                {
                    spriteName = spriteParts.Groups[1].Value;
                    Int32.TryParse(spriteParts.Groups[2].Value, out frame);
                }
                else
                {
                    spriteName = stripped; // Single-frame sprite
                }

                UndertaleTexturePageItem texturePageItem = new();
                texturePageItem.Name = new UndertaleString($"PageItem {++lastTextPageItem}");
                texturePageItem.SourceX = (ushort)n.Bounds.X;
                texturePageItem.SourceY = (ushort)n.Bounds.Y;
                texturePageItem.SourceWidth = (ushort)n.Bounds.Width;
                texturePageItem.SourceHeight = (ushort)n.Bounds.Height;
                texturePageItem.TargetX = (ushort)n.Texture.TargetX;
                texturePageItem.TargetY = (ushort)n.Texture.TargetY;
                texturePageItem.TargetWidth = (ushort)n.Bounds.Width;
                texturePageItem.TargetHeight = (ushort)n.Bounds.Height;
                texturePageItem.BoundingWidth = (ushort)n.Texture.BoundingWidth;
                texturePageItem.BoundingHeight = (ushort)n.Texture.BoundingHeight;
                texturePageItem.TexturePage = texture;

                Data.TexturePageItems.Add(texturePageItem);

                UndertaleSprite.TextureEntry texentry = new();
                texentry.Texture = texturePageItem;

                UndertaleSprite sprite = Data.Sprites.ByName(spriteName);
                if (sprite is null)
                {
                    UndertaleString spriteUTString = Data.Strings.MakeString(spriteName);
                    UndertaleSprite newSprite = new();
                    newSprite.Name = spriteUTString;
                    newSprite.Width = (uint)n.Texture.BoundingWidth;
                    newSprite.Height = (uint)n.Texture.BoundingHeight;
                    newSprite.MarginLeft = n.Texture.TargetX;
                    newSprite.MarginRight = n.Texture.TargetX + n.Bounds.Width - 1;
                    newSprite.MarginTop = n.Texture.TargetY;
                    newSprite.MarginBottom = n.Texture.TargetY + n.Bounds.Height - 1;
                    newSprite.OriginX = 0;
                    newSprite.OriginY = 0;
                    if (frame > 0)
                    {
                        for (int i = 0; i < frame; i++)
                            newSprite.Textures.Add(null);
                    }

                    if (!noMasksForBasicRectangles ||
                        newSprite.SepMasks is not (UndertaleSprite.SepMaskType.AxisAlignedRect or UndertaleSprite.SepMaskType.RotatedRect))
                    {
                        maskNodes.Add(newSprite, n);
                    }

                    newSprite.Textures.Add(texentry);
                    Data.Sprites.Add(newSprite);
                    Console.WriteLine($"Created new sprite: {spriteName}");
                    continue;
                }

                if (frame > sprite.Textures.Count - 1)
                {
                    while (frame > sprite.Textures.Count - 1)
                    {
                        sprite.Textures.Add(texentry);
                    }
                    Console.WriteLine($"Added frame {frame} to existing sprite: {spriteName}");
                    continue;
                }

                sprite.Textures[frame] = texentry;
                Console.WriteLine($"Replaced frame {frame} for sprite: {spriteName}");

                // Rest of the sprite update logic remains unchanged
                uint oldWidth = sprite.Width, oldHeight = sprite.Height;
                sprite.Width = (uint)n.Texture.BoundingWidth;
                sprite.Height = (uint)n.Texture.BoundingHeight;
                bool changedSpriteDimensions = (oldWidth != sprite.Width || oldHeight != sprite.Height);

                bool grewBoundingBox = false;
                bool fullImageBbox = sprite.BBoxMode == 1;
                bool manualBbox = sprite.BBoxMode == 2;
                if (!manualBbox)
                {
                    int marginLeft = fullImageBbox ? 0 : n.Texture.TargetX;
                    int marginRight = fullImageBbox ? ((int)sprite.Width - 1) : (n.Texture.TargetX + n.Bounds.Width - 1);
                    int marginTop = fullImageBbox ? 0 : n.Texture.TargetY;
                    int marginBottom = fullImageBbox ? ((int)sprite.Height - 1) : (n.Texture.TargetY + n.Bounds.Height - 1);
                    if (marginLeft < sprite.MarginLeft)
                    {
                        sprite.MarginLeft = marginLeft;
                        grewBoundingBox = true;
                    }
                    if (marginTop < sprite.MarginTop)
                    {
                        sprite.MarginTop = marginTop;
                        grewBoundingBox = true;
                    }
                    if (marginRight > sprite.MarginRight)
                    {
                        sprite.MarginRight = marginRight;
                        grewBoundingBox = true;
                    }
                    if (marginBottom > sprite.MarginBottom)
                    {
                        sprite.MarginBottom = marginBottom;
                        grewBoundingBox = true;
                    }
                }

                if (!noMasksForBasicRectangles ||
                    sprite.SepMasks is not (UndertaleSprite.SepMaskType.AxisAlignedRect or UndertaleSprite.SepMaskType.RotatedRect) ||
                    sprite.CollisionMasks.Count > 0)
                {
                    if ((bboxMasks && grewBoundingBox) ||
                        (sprite.SepMasks is UndertaleSprite.SepMaskType.Precise && sprite.CollisionMasks.Count == 0) ||
                        (!bboxMasks && changedSpriteDimensions))
                    {
                        maskNodes[sprite] = n;
                    }
                }
            }
        }

        foreach ((UndertaleSprite maskSpr, Node maskNode) in maskNodes)
        {
            maskSpr.CollisionMasks.Clear();
            maskSpr.CollisionMasks.Add(maskSpr.NewMaskEntry(Data));
            (int maskWidth, int maskHeight) = maskSpr.CalculateMaskDimensions(Data);
            int maskStride = ((maskWidth + 7) / 8) * 8;

            BitArray maskingBitArray = new BitArray(maskStride * maskHeight);
            for (int y = 0; y < maskHeight && y < maskNode.Bounds.Height; y++)
            {
                for (int x = 0; x < maskWidth && x < maskNode.Bounds.Width; x++)
                {
                    IMagickColor<byte> pixelColor = atlasPixels.GetPixel(x + maskNode.Bounds.X, y + maskNode.Bounds.Y).ToColor();
                    if (bboxMasks)
                    {
                        maskingBitArray[(y * maskStride) + x] = (pixelColor.A > 0);
                    }
                    else
                    {
                        maskingBitArray[((y + maskNode.Texture.TargetY) * maskStride) + x + maskNode.Texture.TargetX] = (pixelColor.A > 0);
                    }
                }
            }
            BitArray tempBitArray = new BitArray(maskingBitArray.Length);
            for (int i = 0; i < maskingBitArray.Length; i += 8)
            {
                for (int j = 0; j < 8; j++)
                {
                    tempBitArray[j + i] = maskingBitArray[-(j - 7) + i];
                }
            }

            int numBytes = maskingBitArray.Length / 8;
            byte[] bytes = new byte[numBytes];
            tempBitArray.CopyTo(bytes, 0);
            for (int i = 0; i < bytes.Length; i++)
                maskSpr.CollisionMasks[0].Data[i] = bytes[i];
        }
        maskNodes.Clear();

        atlasCount++;
    }

    Console.WriteLine("Import Complete!");
}
finally
{
    foreach (MagickImage img in imagesToCleanup)
    {
        img.Dispose();
    }
}

public class TextureInfo
{
    public string Source;
    public int Width;
    public int Height;
    public int TargetX;
    public int TargetY;
    public int BoundingWidth;
    public int BoundingHeight;
    public MagickImage Image;
}

public enum SpriteType
{
    Sprite,
    Background,
    Font,
    Unknown
}

public enum SplitType
{
    Horizontal,
    Vertical,
}

public enum BestFitHeuristic
{
    Area,
    MaxOneAxis,
}

public struct Rect
{
    public int X { get; set; }
    public int Y { get; set; }
    public int Width { get; set; }
    public int Height { get; set; }
}

public class Node
{
    public Rect Bounds;
    public TextureInfo Texture;
    public SplitType SplitType;
}

public class Atlas
{
    public int Width;
    public int Height;
    public List<Node> Nodes;
}

public class Packer
{
    public List<TextureInfo> SourceTextures;
    public StringWriter Log;
    public StringWriter Error;
    public int Padding;
    public int AtlasSize;
    public bool DebugMode;
    public BestFitHeuristic FitHeuristic;
    public List<Atlas> Atlasses;

    public Packer()
    {
        SourceTextures = new List<TextureInfo>();
        Log = new StringWriter();
        Error = new StringWriter();
        FitHeuristic = BestFitHeuristic.MaxOneAxis;
    }

    public void Process(string _SourceDir, string _Pattern, int _AtlasSize, int _Padding, bool _DebugMode)
    {
        Padding = _Padding;
        AtlasSize = _AtlasSize;
        DebugMode = _DebugMode;
        ScanForTextures(_SourceDir, _Pattern);
        List<TextureInfo> textures = SourceTextures.ToList();
        Atlasses = new List<Atlas>();
        while (textures.Count > 0)
        {
            Atlas atlas = new Atlas();
            atlas.Width = _AtlasSize;
            atlas.Height = _AtlasSize;
            List<TextureInfo> leftovers = LayoutAtlas(textures, atlas);
            if (leftovers.Count == 0)
            {
                while (leftovers.Count == 0)
                {
                    atlas.Width /= 2;
                    atlas.Height /= 2;
                    leftovers = LayoutAtlas(textures, atlas);
                }
                if (atlas.Width == 0) atlas.Width = 1;
                else atlas.Width *= 2;
                if (atlas.Height == 0) atlas.Height = 1;
                else atlas.Height *= 2;
                leftovers = LayoutAtlas(textures, atlas);
            }
            Atlasses.Add(atlas);
            textures = leftovers;
        }
    }

    public void SaveAtlasses(string _Destination)
    {
        int atlasCount = 0;
        string prefix = _Destination.Replace(Path.GetExtension(_Destination), "");
        string descFile = _Destination;

        StreamWriter tw = new StreamWriter(_Destination);
        tw.WriteLine("source_tex, atlas_tex, x, y, width, height");
        foreach (Atlas atlas in Atlasses)
        {
            string atlasName = $"{prefix}{atlasCount:000}.png";
            using (MagickImage img = CreateAtlasImage(atlas))
                TextureWorker.SaveImageToFile(img, atlasName);
            foreach (Node n in atlas.Nodes)
            {
                if (n.Texture != null)
                {
                    tw.Write(n.Texture.Source + ", ");
                    tw.Write(atlasName + ", ");
                    tw.Write((n.Bounds.X).ToString() + ", ");
                    tw.Write((n.Bounds.Y).ToString() + ", ");
                    tw.Write((n.Bounds.Width).ToString() + ", ");
                    tw.WriteLine((n.Bounds.Height).ToString());
                }
            }
            ++atlasCount;
        }
        tw.Close();
        tw = new StreamWriter(prefix + ".log");
        tw.WriteLine("--- LOG -------------------------------------------");
        tw.WriteLine(Log.ToString());
        tw.WriteLine("--- ERROR -----------------------------------------");
        tw.WriteLine(Error.ToString());
        tw.Close();
    }

    private void ScanForTextures(string _Path, string _Wildcard)
    {
        DirectoryInfo di = new(_Path);
        FileInfo[] files = di.GetFiles(_Wildcard, SearchOption.AllDirectories);
        foreach (FileInfo fi in files)
        {
            (int width, int height) = TextureWorker.GetImageSizeFromFile(fi.FullName);
            if (width == -1 || height == -1)
                continue;

            if (width <= AtlasSize && height <= AtlasSize)
            {
                TextureInfo ti = new();
                MagickReadSettings settings = new() { ColorSpace = ColorSpace.sRGB };
                MagickImage img = new(fi.FullName);
                imagesToCleanup.Add(img);

                ti.Source = fi.FullName;
                ti.BoundingWidth = (int)img.Width;
                ti.BoundingHeight = (int)img.Height;
                ti.TargetX = 0;
                ti.TargetY = 0;
                if (GetSpriteType(ti.Source) != SpriteType.Background)
                {
                    img.BorderColor = MagickColors.Transparent;
                    img.BackgroundColor = MagickColors.Transparent;
                    img.Border(1);
                    IMagickGeometry? bbox = img.BoundingBox;
                    if (bbox is not null)
                    {
                        ti.TargetX = bbox.X - 1;
                        ti.TargetY = bbox.Y - 1;
                        img.Trim();
                    }
                    else
                    {
                        ti.TargetX = 0;
                        ti.TargetY = 0;
                        img.Crop(1, 1);
                    }
                    img.ResetPage();
                }
                ti.Width = (int)img.Width;
                ti.Height = (int)img.Height;
                ti.Image = img;

                SourceTextures.Add(ti);
                Log.WriteLine($"Added {fi.FullName}");
            }
            else
            {
                Error.WriteLine($"{fi.FullName} is too large to fit in the atlas. Skipping!");
            }
        }
    }

    private void HorizontalSplit(Node _ToSplit, int _Width, int _Height, List<Node> _List)
    {
        Node n1 = new Node();
        n1.Bounds.X = _ToSplit.Bounds.X + _Width + Padding;
        n1.Bounds.Y = _ToSplit.Bounds.Y;
        n1.Bounds.Width = _ToSplit.Bounds.Width - _Width - Padding;
        n1.Bounds.Height = _Height;
        n1.SplitType = SplitType.Vertical;
        Node n2 = new Node();
        n2.Bounds.X = _ToSplit.Bounds.X;
        n2.Bounds.Y = _ToSplit.Bounds.Y + _Height + Padding;
        n2.Bounds.Width = _ToSplit.Bounds.Width;
        n2.Bounds.Height = _ToSplit.Bounds.Height - _Height - Padding;
        n2.SplitType = SplitType.Horizontal;
        if (n1.Bounds.Width > 0 && n1.Bounds.Height > 0)
            _List.Add(n1);
        if (n2.Bounds.Width > 0 && n2.Bounds.Height > 0)
            _List.Add(n2);
    }

    private void VerticalSplit(Node _ToSplit, int _Width, int _Height, List<Node> _List)
    {
        Node n1 = new Node();
        n1.Bounds.X = _ToSplit.Bounds.X + _Width + Padding;
        n1.Bounds.Y = _ToSplit.Bounds.Y;
        n1.Bounds.Width = _ToSplit.Bounds.Width - _Width - Padding;
        n1.Bounds.Height = _ToSplit.Bounds.Height;
        n1.SplitType = SplitType.Vertical;
        Node n2 = new Node();
        n2.Bounds.X = _ToSplit.Bounds.X;
        n2.Bounds.Y = _ToSplit.Bounds.Y + _Height + Padding;
        n2.Bounds.Width = _Width;
        n2.Bounds.Height = _ToSplit.Bounds.Height - _Height - Padding;
        n2.SplitType = SplitType.Horizontal;
        if (n1.Bounds.Width > 0 && n1.Bounds.Height > 0)
            _List.Add(n1);
        if (n2.Bounds.Width > 0 && n2.Bounds.Height > 0)
            _List.Add(n2);
    }

    private TextureInfo FindBestFitForNode(Node _Node, List<TextureInfo> _Textures)
    {
        TextureInfo bestFit = null;
        float nodeArea = _Node.Bounds.Width * _Node.Bounds.Height;
        float maxCriteria = 0.0f;
        foreach (TextureInfo ti in _Textures)
        {
            switch (FitHeuristic)
            {
                case BestFitHeuristic.MaxOneAxis:
                    if (ti.Width <= _Node.Bounds.Width && ti.Height <= _Node.Bounds.Height)
                    {
                        float wRatio = (float)ti.Width / (float)_Node.Bounds.Width;
                        float hRatio = (float)ti.Height / (float)_Node.Bounds.Height;
                        float ratio = wRatio > hRatio ? wRatio : hRatio;
                        if (ratio > maxCriteria)
                        {
                            maxCriteria = ratio;
                            bestFit = ti;
                        }
                    }
                    break;
                case BestFitHeuristic.Area:
                    if (ti.Width <= _Node.Bounds.Width && ti.Height <= _Node.Bounds.Height)
                    {
                        float textureArea = ti.Width * ti.Height;
                        float coverage = textureArea / nodeArea;
                        if (coverage > maxCriteria)
                        {
                            maxCriteria = coverage;
                            bestFit = ti;
                        }
                    }
                    break;
            }
        }
        return bestFit;
    }

    private List<TextureInfo> LayoutAtlas(List<TextureInfo> _Textures, Atlas _Atlas)
    {
        List<Node> freeList = new List<Node>();
        List<TextureInfo> textures = _Textures.ToList();
        _Atlas.Nodes = new List<Node>();
        Node root = new Node();
        root.Bounds.Width = _Atlas.Width;
        root.Bounds.Height = _Atlas.Height;
        root.SplitType = SplitType.Horizontal;
        freeList.Add(root);
        while (freeList.Count > 0 && textures.Count > 0)
        {
            Node node = freeList[0];
            freeList.RemoveAt(0);
            TextureInfo bestFit = FindBestFitForNode(node, textures);
            if (bestFit != null)
            {
                if (node.SplitType == SplitType.Horizontal)
                {
                    HorizontalSplit(node, bestFit.Width, bestFit.Height, freeList);
                }
                else
                {
                    VerticalSplit(node, bestFit.Width, bestFit.Height, freeList);
                }
                node.Texture = bestFit;
                node.Bounds.Width = bestFit.Width;
                node.Bounds.Height = bestFit.Height;
                textures.Remove(bestFit);
            }
            _Atlas.Nodes.Add(node);
        }
        return textures;
    }

    private MagickImage CreateAtlasImage(Atlas _Atlas)
    {
        MagickImage img = new(MagickColors.Transparent, (uint)_Atlas.Width, (uint)_Atlas.Height);
        foreach (Node n in _Atlas.Nodes)
        {
            if (n.Texture is not null)
            {
                MagickImage sourceImg = n.Texture.Image;
                using IMagickImage<byte> resizedSourceImg = TextureWorker.ResizeImage(sourceImg, n.Bounds.Width, n.Bounds.Height);
                img.Composite(resizedSourceImg, n.Bounds.X, n.Bounds.Y, CompositeOperator.Copy);
            }
        }
        return img;
    }
}

public static SpriteType GetSpriteType(string path)
{
    string folderPath = Path.GetDirectoryName(path);
    string folderName = new DirectoryInfo(folderPath).Name;
    string lowerName = folderName.ToLower();

    if (lowerName == "backgrounds" || lowerName == "background")
        return SpriteType.Background;
    else if (lowerName == "fonts" || lowerName == "font")
        return SpriteType.Font;
    else if (lowerName == "sprites" || lowerName == "sprite")
        return SpriteType.Sprite;
    return SpriteType.Unknown;
}