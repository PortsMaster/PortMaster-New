using System;
using System.IO;
using System.Threading.Tasks;
using UndertaleModLib.Util;
using System.Collections.Generic;
using UndertaleModLib.Models;

// Read arguments from environment variables
string texFolder = Environment.GetEnvironmentVariable("UMT_SPRITES_FOLDER");
string paddedStr = Environment.GetEnvironmentVariable("UMT_PADDED");
string spriteNamesStr = Environment.GetEnvironmentVariable("UMT_SPRITE_NAMES");
string spritePrefix = Environment.GetEnvironmentVariable("UMT_SPRITE_PREFIX");

if (string.IsNullOrEmpty(texFolder) || string.IsNullOrEmpty(paddedStr))
{
    Console.WriteLine("Error: Required environment variables not set.");
    Console.WriteLine("Usage: Set UMT_SPRITES_FOLDER and UMT_PADDED.");
    Console.WriteLine("Set either UMT_SPRITE_NAMES or UMT_SPRITE_PREFIX.");
    return;
}

if (string.IsNullOrEmpty(spriteNamesStr) && string.IsNullOrEmpty(spritePrefix))
{
    Console.WriteLine("Error: You must specify either UMT_SPRITE_NAMES or UMT_SPRITE_PREFIX.");
    return;
}

bool padded;
if (!bool.TryParse(paddedStr, out padded))
{
    Console.WriteLine("Error: UMT_PADDED must be 'true' or 'false'");
    return;
}

string[] spriteNames = spriteNamesStr?.Split(',', StringSplitOptions.RemoveEmptyEntries) ?? Array.Empty<string>();

EnsureDataLoaded();
Directory.CreateDirectory(texFolder); // Ensure output folder exists

List<UndertaleSprite> spritesToDump = new();

foreach (UndertaleSprite spr in Data.Sprites)
{
    if (spr is null) continue;

    // Match if name is in list
    bool nameMatch = Array.Exists(spriteNames, s => s.Trim().Equals(spr.Name.Content, StringComparison.InvariantCultureIgnoreCase));

    // Match if prefix is used
    bool prefixMatch = !string.IsNullOrEmpty(spritePrefix) &&
                       spr.Name.Content.StartsWith(spritePrefix, StringComparison.InvariantCultureIgnoreCase);

    if (nameMatch || prefixMatch)
    {
        spritesToDump.Add(spr);
    }
}

Console.WriteLine($"Found {spritesToDump.Count} sprites to export");

TextureWorker worker = null;
using (worker = new())
{
    await Task.Run(() =>
    {
        int progress = 0;
        foreach (UndertaleSprite sprToDump in spritesToDump)
        {
            DumpSprite(sprToDump);
            progress++;
            Console.WriteLine($"Exported sprite {progress}/{spritesToDump.Count}: {sprToDump.Name.Content}");
        }
    });
}

void DumpSprite(UndertaleSprite sprite)
{
    for (int i = 0; i < sprite.Textures.Count; i++)
    {
        if (sprite.Textures[i]?.Texture is not null)
        {
            worker.ExportAsPNG(sprite.Textures[i].Texture, Path.Combine(texFolder, $"{sprite.Name.Content}_{i}.png"), null, padded);
        }
    }
}