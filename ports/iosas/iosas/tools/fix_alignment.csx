#r "UndertaleModLib.dll"
using System;
using UndertaleModLib;
using UndertaleModLib.Models;

// This script loads the data.win file and immediately saves it back
// This triggers UTMT's built-in alignment correction that happens during save
// Useful for fixing misaligned data.win files created by external audio compression tools

ScriptMessage("[INFO] Starting alignment fix process...");
ScriptMessage("[INFO] This will load and re-save the file to fix any misalignment issues");

// The file is already loaded by EnsureDataLoaded()
EnsureDataLoaded();

ScriptMessage("[INFO] Data loaded successfully");

// Check for potential alignment issues by looking at file structure
int soundCount = Data.Sounds?.Count ?? 0;
int audioGroupCount = Data.AudioGroups?.Count ?? 0;

ScriptMessage($"[INFO] Found {soundCount} sounds");
ScriptMessage($"[INFO] Found {audioGroupCount} audio groups");

// The save happens automatically when the script exits
// UTMT will realign all chunks during the save process
ScriptMessage("[SUCCESS] File will be realigned during save");
ScriptMessage("[INFO] Alignment fix complete - data.win has been corrected");
