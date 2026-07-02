using System;
using UndertaleModLib;
using UndertaleModLib.Models;

EnsureDataLoaded();

var gi = Data.GeneralInfo;

ScriptMessage($"[INFO] Current InfoFlags: {gi.Info}");
ScriptMessage($"[INFO] Scale currently: {(gi.Info.HasFlag(UndertaleGeneralInfo.InfoFlags.Scale) ? "ENABLED" : "DISABLED")}");

// Always enable Scale
gi.Info |= UndertaleGeneralInfo.InfoFlags.Scale;

ScriptMessage($"[INFO] Enabled Scale flag");

ScriptMessage($"[INFO] New InfoFlags: {gi.Info}");
ScriptMessage($"[INFO] Scale now: {(gi.Info.HasFlag(UndertaleGeneralInfo.InfoFlags.Scale) ? "ENABLED" : "DISABLED")}");