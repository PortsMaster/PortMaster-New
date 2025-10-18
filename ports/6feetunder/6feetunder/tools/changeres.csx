#r "UndertaleModLib.dll"
using System;
using UndertaleModLib;
using UndertaleModLib.Models;

EnsureDataLoaded();

var gi = Data.GeneralInfo;

var widthStr = Environment.GetEnvironmentVariable("WINDOW_WIDTH") ?? "";
var heightStr = Environment.GetEnvironmentVariable("WINDOW_HEIGHT") ?? "";

ScriptMessage($"[INFO] Current window dimensions: {gi.DefaultWindowWidth}x{gi.DefaultWindowHeight}");

// Set window dimensions if provided
if (!string.IsNullOrWhiteSpace(widthStr) && uint.TryParse(widthStr, out uint width))
{
    gi.DefaultWindowWidth = width;
    ScriptMessage($"[INFO] Set DefaultWindowWidth to {width}");
}

if (!string.IsNullOrWhiteSpace(heightStr) && uint.TryParse(heightStr, out uint height))
{
    gi.DefaultWindowHeight = height;
    ScriptMessage($"[INFO] Set DefaultWindowHeight to {height}");
}

ScriptMessage($"[INFO] New window dimensions: {gi.DefaultWindowWidth}x{gi.DefaultWindowHeight}");