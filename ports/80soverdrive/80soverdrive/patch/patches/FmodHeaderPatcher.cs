// FmodHeaderPatcher.cs
// ChaiFoxes.FMODAudio.Desktop.dll binds FMOD 2.00.08: FMOD5_System_Create(FMOD_SYSTEM**) has ONE argument.
// FMOD 2.02.x (libfmod.so.13) is FMOD_System_Create(FMOD_SYSTEM**, unsigned headerversion) and returns
// FMOD_ERR_HEADER_MISMATCH (0x14) unless (headerversion >> 8) == 0x202. ChaiFoxes ignores every FMOD RESULT,
// so the system handle stays null and every later call fails silently.
// This patch adds the missing argument (0x00020200) to the P/Invoke and to Factory.System_Create.
using System;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using Mono.Cecil;
using Mono.Cecil.Cil;

static class FmodHeaderPatcher
{
    const int HeaderVersion = 0x00020200;
    static string Hex(byte[] b) { return BitConverter.ToString(b).Replace("-", "").ToLowerInvariant(); }
    static int Fail(string m) { Console.Error.WriteLine("ERROR: " + m); return 1; }

    static int Main(string[] a)
    {
        if (a.Length < 2 || a.Length > 3) { Console.Error.WriteLine("usage: mono FmodHeaderPatcher.exe <in ChaiFoxes.FMODAudio.Desktop.dll> <out.dll> [folder with MonoGame.Framework.dll]"); return 2; }
        string inP = Path.GetFullPath(a[0]), outP = Path.GetFullPath(a[1]);
        if (inP == outP) return Fail("output must differ from input");
        Console.WriteLine("input sha256 : " + Hex(SHA256.Create().ComputeHash(File.ReadAllBytes(inP))));
        var r = new DefaultAssemblyResolver(); r.AddSearchDirectory(Path.GetDirectoryName(inP));
        if (a.Length == 3) r.AddSearchDirectory(Path.GetFullPath(a[2]));
        var asm = AssemblyDefinition.ReadAssembly(inP, new ReaderParameters { AssemblyResolver = r });
        var mod = asm.MainModule;
        var f = mod.GetType("FMOD.Factory");
        if (f == null) return Fail("FMOD.Factory not found");
        var pinv = f.Methods.FirstOrDefault(m => m.Name == "FMOD5_System_Create");
        var wrap = f.Methods.FirstOrDefault(m => m.Name == "System_Create");
        if (pinv == null || wrap == null) return Fail("methods not found");
        if (!pinv.IsPInvokeImpl || pinv.Parameters.Count != 1) return Fail("FMOD5_System_Create: not the expected 1-arg P/Invoke (already patched?)");
        var calls = wrap.Body.Instructions.Where(i => i.OpCode == OpCodes.Call && ((MethodReference)i.Operand).Name == "FMOD5_System_Create").ToList();
        if (calls.Count != 1) return Fail("System_Create: expected exactly one call to FMOD5_System_Create");

        pinv.Parameters.Add(new ParameterDefinition("headerversion", ParameterAttributes.None, mod.TypeSystem.UInt32));
        wrap.Body.GetILProcessor().InsertBefore(calls[0], Instruction.Create(OpCodes.Ldc_I4, HeaderVersion));
        Console.WriteLine("patched      : FMOD.Factory.FMOD5_System_Create(out handle, uint headerversion=0x" + HeaderVersion.ToString("X8") + ")");
        asm.Write(outP);
        Console.WriteLine("output sha256: " + Hex(SHA256.Create().ComputeHash(File.ReadAllBytes(outP))));
        return 0;
    }
}
