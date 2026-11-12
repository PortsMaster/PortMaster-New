// OverdriveSteamPatcher.cs
// Makes the Steam integration of 80's Overdrive (Windows/Steam depot 1381446) optional on
// Linux/macOS so the managed 80s_Overdrive.exe can boot under ARM64 Mono (PortMaster/Knulli).
//
// Input is never modified. A patched copy is written to the output path.
// Build: see build.sh (needs Mono's mcs + Mono.Cecil 0.11.x).

using System;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using Mono.Cecil;
using Mono.Cecil.Cil;

static class OverdriveSteamPatcher
{
    const string ExpectedSha256 = "9dd910bd908e6089ee102e30dff735fe7d1059eb6511f622180d6dbdfe592191";

    static int Fail(string msg) { Console.Error.WriteLine("ERROR: " + msg); return 1; }

    static int Main(string[] args)
    {
        if (args.Length < 2 || args.Length > 3)
        {
            Console.Error.WriteLine("usage: mono OverdriveSteamPatcher.exe <original 80s_Overdrive.exe> <patched output.exe> [folder with MonoGame.Framework.dll]");
            return 2;
        }
        string inPath = Path.GetFullPath(args[0]), outPath = Path.GetFullPath(args[1]);
        if (inPath == outPath) return Fail("output must differ from input (the original is never modified in place)");

        string sha = Hex(SHA256.Create().ComputeHash(File.ReadAllBytes(inPath)));
        Console.WriteLine("input sha256 : " + sha);
        if (sha != ExpectedSha256)
            Console.WriteLine("WARNING: input differs from the build this patcher was written against; continuing only if the IL shape validates.");

        // Cecil must resolve MonoGame.Framework.dll (enum default-parameter constants) when writing,
        // so keep the original depot's DLLs next to the input exe (or pass their folder as 3rd arg).
        var resolver = new DefaultAssemblyResolver();
        resolver.AddSearchDirectory(Path.GetDirectoryName(inPath));
        if (args.Length == 3) resolver.AddSearchDirectory(Path.GetFullPath(args[2]));
        var asm = AssemblyDefinition.ReadAssembly(inPath, new ReaderParameters { AssemblyResolver = resolver });
        var mod = asm.MainModule;

        var steamApi = mod.GetType("PlatformAPI.Desktop.Steam.SteamAPI");
        var mgr = mod.GetType("GameEngine.Engine.achievements.desktop.SteamAchievementsManager");
        if (steamApi == null || mgr == null) return Fail("expected types not found");

        var loadLib = steamApi.Methods.FirstOrDefault(m => m.Name == "LoadSteamLib");
        var isAvail = steamApi.Methods.FirstOrDefault(m => m.Name == "get_IsSteamAvailable");
        var init = mgr.Methods.FirstOrDefault(m => m.Name == "Init");
        var isReset = mgr.Methods.FirstOrDefault(m => m.Name == "IsResetRequired");
        var sendStats = mgr.Methods.FirstOrDefault(m => m.Name == "SendStats");
        if (loadLib == null || isAvail == null || init == null || isReset == null || sendStats == null)
            return Fail("expected methods not found");

        var intPtrZero = mod.ImportReference(typeof(IntPtr).GetField("Zero"));

        // ---- Patch 1: SteamAPI.LoadSteamLib -> on Linux/macOS never dlopen libsteam_api.so ----
        {
            var il = loadLib.Body.Instructions;
            // Validate: original has "call OSPlatform.get_Linux" at IL_0029 and ends with ret.
            var linux = il.FirstOrDefault(i => i.Offset == 0x29);
            if (linux == null || linux.OpCode != OpCodes.Call || !linux.Operand.ToString().Contains("get_Linux"))
                return Fail("LoadSteamLib: unexpected IL (no get_Linux call at IL_0029)");
            if (!il.Any(i => i.Operand is string s && s == "libsteam_api.so"))
                return Fail("LoadSteamLib: libsteam_api.so literal not found");
            int idx = il.IndexOf(linux);
            while (il.Count > idx + 1) il.RemoveAt(il.Count - 1);
            // Reuse the existing IL_0029 instruction object: the Windows branch (brfalse IL_0029) targets it.
            linux.OpCode = OpCodes.Ldsfld;
            linux.Operand = intPtrZero;
            il.Add(Instruction.Create(OpCodes.Ret));
            Widen(loadLib.Body);
            Console.WriteLine("patched      : SteamAPI.LoadSteamLib (non-Windows -> IntPtr.Zero)");
        }

        // ---- Patch 2: SteamAchievementsManager.Init -> behave like SteamAPI_Init()==false ----
        {
            var il = init.Body.Instructions;
            var first = il.FirstOrDefault(i => i.OpCode == OpCodes.Ldsfld && ((FieldReference)i.Operand).Name == "Init"
                                               && ((FieldReference)i.Operand).DeclaringType.FullName == steamApi.FullName);
            var ret = il.Last();
            if (first == null || ret.OpCode != OpCodes.Ret) return Fail("Init: unexpected IL");
            var ilp = init.Body.GetILProcessor();
            ilp.InsertBefore(first, Instruction.Create(OpCodes.Call, isAvail));
            ilp.InsertBefore(first, Instruction.Create(OpCodes.Brfalse, ret));
            Widen(init.Body);
            Console.WriteLine("patched      : SteamAchievementsManager.Init (return if !SteamAPI.IsSteamAvailable)");
        }

        // ---- Patch 3: IsResetRequired -> false when Steam unavailable ----
        {
            var il = isReset.Body.Instructions;
            var first = il[0];
            if (!il.Any(i => i.OpCode == OpCodes.Ldsfld && ((FieldReference)i.Operand).Name == "RestartAppIfNecessary"))
                return Fail("IsResetRequired: unexpected IL");
            var ilp = isReset.Body.GetILProcessor();
            ilp.InsertBefore(first, Instruction.Create(OpCodes.Call, isAvail));
            ilp.InsertBefore(first, Instruction.Create(OpCodes.Brtrue, first));
            ilp.InsertBefore(first, Instruction.Create(OpCodes.Ldc_I4_0));
            ilp.InsertBefore(first, Instruction.Create(OpCodes.Ret));
            Widen(isReset.Body);
            Console.WriteLine("patched      : SteamAchievementsManager.IsResetRequired (false when !IsSteamAvailable)");
        }

        // ---- Patch 4: SendStats -> no-op when Steam unavailable ----
        {
            var il = sendStats.Body.Instructions;
            var first = il[0];
            if (!il.Any(i => i.OpCode == OpCodes.Ldsfld && ((FieldReference)i.Operand).Name == "SteamUserStats_StoreStats"))
                return Fail("SendStats: unexpected IL");
            var ilp = sendStats.Body.GetILProcessor();
            ilp.InsertBefore(first, Instruction.Create(OpCodes.Call, isAvail));
            ilp.InsertBefore(first, Instruction.Create(OpCodes.Brtrue, first));
            ilp.InsertBefore(first, Instruction.Create(OpCodes.Ret));
            Widen(sendStats.Body);
            Console.WriteLine("patched      : SteamAchievementsManager.SendStats (no-op when !IsSteamAvailable)");
        }

        foreach (var m in new[] { loadLib, init, isReset, sendStats })
        {
            var set = m.Body.Instructions;
            foreach (var i in set)
            {
                var t = i.Operand as Instruction;
                if (t != null && !set.Contains(t)) return Fail(m.Name + ": branch target outside method body");
                var ts = i.Operand as Instruction[];
                if (ts != null && ts.Any(x => !set.Contains(x))) return Fail(m.Name + ": switch target outside method body");
            }
            if (set.Last().OpCode != OpCodes.Ret) return Fail(m.Name + ": does not end in ret");
        }

        if (mod.EntryPoint == null || mod.EntryPoint.FullName.IndexOf("GameEngine.Program::Main", StringComparison.Ordinal) < 0)
            return Fail("entry point is not GameEngine.Program.Main");

        asm.Write(outPath);
        Console.WriteLine("output       : " + outPath);
        Console.WriteLine("output sha256: " + Hex(SHA256.Create().ComputeHash(File.ReadAllBytes(outPath))));
        return 0;
    }


    // Short-form branches can overflow after inserting instructions; widen every *_S branch to its long form.
    static void Widen(MethodBody body)
    {
        foreach (var i in body.Instructions)
        {
            var op = i.OpCode;
            if (op == OpCodes.Br_S) i.OpCode = OpCodes.Br;
            else if (op == OpCodes.Brfalse_S) i.OpCode = OpCodes.Brfalse;
            else if (op == OpCodes.Brtrue_S) i.OpCode = OpCodes.Brtrue;
            else if (op == OpCodes.Beq_S) i.OpCode = OpCodes.Beq;
            else if (op == OpCodes.Bge_S) i.OpCode = OpCodes.Bge;
            else if (op == OpCodes.Bgt_S) i.OpCode = OpCodes.Bgt;
            else if (op == OpCodes.Ble_S) i.OpCode = OpCodes.Ble;
            else if (op == OpCodes.Blt_S) i.OpCode = OpCodes.Blt;
            else if (op == OpCodes.Bne_Un_S) i.OpCode = OpCodes.Bne_Un;
            else if (op == OpCodes.Bge_Un_S) i.OpCode = OpCodes.Bge_Un;
            else if (op == OpCodes.Bgt_Un_S) i.OpCode = OpCodes.Bgt_Un;
            else if (op == OpCodes.Ble_Un_S) i.OpCode = OpCodes.Ble_Un;
            else if (op == OpCodes.Blt_Un_S) i.OpCode = OpCodes.Blt_Un;
            else if (op == OpCodes.Leave_S) i.OpCode = OpCodes.Leave;
        }
    }

    static string Hex(byte[] b) { return BitConverter.ToString(b).Replace("-", "").ToLowerInvariant(); }
}
