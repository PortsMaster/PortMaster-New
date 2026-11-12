// PatchPad.cs - removes the "has left thumbstick" capability gates from 80's Overdrive
// so that GamePlayState.OnGamePad (A = accelerate, B = brake, D-pad) is called even when
// the SDL/MonoGame pad on Rocknix reports no left-stick axes.
//
// Build:  mcs PatchPad.cs -r:Mono.Cecil.dll -out:PatchPad.exe
// Run:    mono PatchPad.exe 80s_Overdrive.exe [output.exe]
//         (Mono.Cecil.dll 0.11.x must sit next to PatchPad.exe or be in the GAC)
//
// If no output path is given the input is patched in place after a .bak copy is made.
using System;
using System.IO;
using System.Linq;
using Mono.Cecil;
using Mono.Cecil.Cil;

static class PatchPad
{
    static int Main(string[] args)
    {
        if (args.Length < 1)
        {
            Console.Error.WriteLine("usage: mono PatchPad.exe <80s_Overdrive.exe> [output.exe]");
            return 2;
        }
        string input = args[0];
        string output = args.Length > 1 ? args[1] : input;
        string tmp = output + ".tmp";

        if (args.Length < 2 && !File.Exists(input + ".bak"))
            File.Copy(input, input + ".bak");

        int total = 0;
        // The module is read fully into memory by Cecil, so writing back to the same path is fine.
        // Cecil needs to resolve MonoGame.Framework (enum-typed default parameters) when writing,
        // so let it look next to the exe (MonoGame.Framework.dll must be in the game folder).
        var resolver = new DefaultAssemblyResolver();
        resolver.AddSearchDirectory(Path.GetDirectoryName(Path.GetFullPath(input)));
        var asm = AssemblyDefinition.ReadAssembly(input, new ReaderParameters { AssemblyResolver = resolver });

        // BasePadHandler.CheckConnectedPads: gate before OnGamePadPrivate(i) -> GamePlayState.OnGamePad
        total += PatchMethod(asm, "BasePadHandler", "CheckConnectedPads");
        // DesktopPadHandler.ProcessGamepadInput: gate before reading the left stick for navigation keys
        total += PatchMethod(asm, "DesktopPadHandler", "ProcessGamepadInput");

        if (total == 0)
        {
            Console.Error.WriteLine("Nothing patched (already patched, or a different build?).");
            return 1;
        }
        try { asm.Write(tmp); }
        catch (AssemblyResolutionException e)
        {
            Console.Error.WriteLine("Could not resolve {0}. Run this on the exe while it sits in the game folder,", e.AssemblyReference.Name);
            Console.Error.WriteLine("next to MonoGame.Framework.dll and the other game DLLs.");
            return 3;
        }
        if (File.Exists(output)) File.Delete(output);
        File.Move(tmp, output);
        Console.WriteLine("Patched {0} check(s) -> {1}", total, output);
        return 0;
    }

    static int PatchMethod(AssemblyDefinition asm, string typeName, string methodName)
    {
        var type = asm.MainModule.Types.SelectMany(Flatten).FirstOrDefault(t => t.Name == typeName);
        var method = type == null ? null : type.Methods.FirstOrDefault(m => m.Name == methodName && m.HasBody);
        if (method == null)
        {
            Console.Error.WriteLine("  ! {0}::{1} not found", typeName, methodName);
            return 0;
        }

        int n = 0;
        var il = method.Body.Instructions;
        for (int i = 0; i + 1 < il.Count; i++)
        {
            var call = il[i];
            if (call.OpCode.Code != Code.Call || !(call.Operand is MethodReference)) continue;
            string name = ((MethodReference)call.Operand).Name;
            if (name != "get_HasLeftXThumbStick" && name != "get_HasLeftYThumbStick") continue;

            var br = il[i + 1];
            if (br.OpCode.Code != Code.Brfalse && br.OpCode.Code != Code.Brfalse_S) continue; // already patched
            // Keep the stack balanced: the getter pushed a bool, so consume it instead of branching on it.
            br.OpCode = OpCodes.Pop;
            br.Operand = null;
            n++;
            Console.WriteLine("  {0}::{1}: neutralised {2} check at IL_{3:x4}", typeName, methodName, name, call.Offset);
        }
        return n;
    }

    static System.Collections.Generic.IEnumerable<TypeDefinition> Flatten(TypeDefinition t)
    {
        yield return t;
        foreach (var n in t.NestedTypes.SelectMany(Flatten)) yield return n;
    }
}
