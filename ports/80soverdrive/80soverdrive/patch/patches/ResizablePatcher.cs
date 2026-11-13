// ResizablePatcher.cs
// Removes the single `Window.AllowUserResizing = true;` statement from GameEngine.Game1.Initialize().
// Why: MonoGame's SdlGameWindow.set_AllowUserResizing throws unless `Sdl.Patch > 4`, i.e. it tests only the SDL
// *patch* number. SDL 2.30.4 (AmberELEC, libSDL2-2.0.so.0.3000.4) has patch == 4 -> exception, although SDL is new.
// Input must be the Steam-patched 80s_Overdrive.exe (output of OverdriveSteamPatcher). Input is never modified.
using System;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using Mono.Cecil;
using Mono.Cecil.Cil;

static class ResizablePatcher
{
    static string Hex(byte[] b) { return BitConverter.ToString(b).Replace("-", "").ToLowerInvariant(); }
    static int Fail(string m) { Console.Error.WriteLine("ERROR: " + m); return 1; }

    static int Main(string[] a)
    {
        if (a.Length < 2 || a.Length > 3) { Console.Error.WriteLine("usage: mono ResizablePatcher.exe <Steam-patched 80s_Overdrive.exe> <out.exe> [folder with MonoGame.Framework.dll]"); return 2; }
        string inP = Path.GetFullPath(a[0]), outP = Path.GetFullPath(a[1]);
        if (inP == outP) return Fail("output must differ from input");
        Console.WriteLine("input sha256 : " + Hex(SHA256.Create().ComputeHash(File.ReadAllBytes(inP))));
        var r = new DefaultAssemblyResolver(); r.AddSearchDirectory(Path.GetDirectoryName(inP));
        if (a.Length == 3) r.AddSearchDirectory(Path.GetFullPath(a[2]));
        var asm = AssemblyDefinition.ReadAssembly(inP, new ReaderParameters { AssemblyResolver = r });
        var mod = asm.MainModule;

        // Guard: refuse the unpatched depot exe - the Steam patch must already be present.
        var mgr = mod.GetType("GameEngine.Engine.achievements.desktop.SteamAchievementsManager");
        var init = mgr == null ? null : mgr.Methods.FirstOrDefault(m => m.Name == "Init");
        if (init == null || !init.Body.Instructions.Any(i => i.OpCode == OpCodes.Call && ((MethodReference)i.Operand).Name == "get_IsSteamAvailable"))
            return Fail("input does not contain the Steam patch (SteamAchievementsManager.Init guard missing). Use the working KNULLI exe.");

        var g1 = mod.GetType("GameEngine.Game1");
        var m1 = g1 == null ? null : g1.Methods.FirstOrDefault(m => m.Name == "Initialize" && !m.HasParameters);
        if (m1 == null) return Fail("GameEngine.Game1.Initialize not found");
        var il = m1.Body.Instructions;

        var sets = il.Where(i => i.OpCode == OpCodes.Callvirt && ((MethodReference)i.Operand).Name == "set_AllowUserResizing").ToList();
        if (sets.Count != 1) return Fail("expected exactly one set_AllowUserResizing call in Game1.Initialize, found " + sets.Count);
        int k = il.IndexOf(sets[0]);
        // expected: ldarg.0 ; call Game::get_Window ; ldc.i4.1 ; callvirt set_AllowUserResizing
        if (k < 3 || il[k - 1].OpCode != OpCodes.Ldc_I4_1 || il[k - 2].OpCode != OpCodes.Call ||
            !((MethodReference)il[k - 2].Operand).Name.Equals("get_Window") || il[k - 3].OpCode != OpCodes.Ldarg_0 ||
            il[k - 3].Offset != 0x45 || sets[0].Offset != 0x4c)
            return Fail("unexpected IL around AllowUserResizing (expected IL_0045..IL_004c: ldarg.0, call get_Window, ldc.i4.1, callvirt set_AllowUserResizing)");

        // Stack-neutral 4-instruction statement. First instruction becomes nop (keeps any branch target valid), rest removed.
        var first = il[k - 3];
        first.OpCode = OpCodes.Nop; first.Operand = null;
        for (int i = 0; i < 3; i++) il.RemoveAt(k - 2);
        Console.WriteLine("patched      : Game1.Initialize: removed 'Window.AllowUserResizing = true' (IL_0045..IL_004c)");

        foreach (var i in il) { var t = i.Operand as Instruction; if (t != null && !il.Contains(t)) return Fail("dangling branch target"); }
        asm.Write(outP);
        Console.WriteLine("output sha256: " + Hex(SHA256.Create().ComputeHash(File.ReadAllBytes(outP))));
        return 0;
    }
}
