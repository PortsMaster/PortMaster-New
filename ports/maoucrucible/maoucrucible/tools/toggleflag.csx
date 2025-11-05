#r "UndertaleModLib.dll"
using System;
using UndertaleModLib;
using UndertaleModLib.Models;

EnsureDataLoaded();

var gi = Data.GeneralInfo;

var enableInterpolate = Environment.GetEnvironmentVariable("ENABLE_INTERPOLATE") ?? "false";

ScriptMessage($"[INFO] Current InfoFlags: {gi.Info}");
ScriptMessage($"[INFO] Interpolate currently: {(gi.Info.HasFlag(UndertaleGeneralInfo.InfoFlags.Interpolate) ? "ENABLED" : "DISABLED")}");

if (bool.TryParse(enableInterpolate, out bool enable))
{
    if (enable)
    {
        gi.Info |= UndertaleGeneralInfo.InfoFlags.Interpolate;
        ScriptMessage($"[INFO] Enabled Interpolate flag");
    }
    else
    {
        gi.Info &= ~UndertaleGeneralInfo.InfoFlags.Interpolate;
        ScriptMessage($"[INFO] Disabled Interpolate flag");
    }
}

ScriptMessage($"[INFO] New InfoFlags: {gi.Info}");
ScriptMessage($"[INFO] Interpolate now: {(gi.Info.HasFlag(UndertaleGeneralInfo.InfoFlags.Interpolate) ? "ENABLED" : "DISABLED")}");