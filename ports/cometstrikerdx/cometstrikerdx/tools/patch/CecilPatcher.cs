using System;
using System.Collections.Generic;
using System.Linq;
using Mono.Cecil;
using Mono.Cecil.Cil;

class Patcher
{
    // Clones members of `sourceType` (from a small standalone helper assembly)
    // into `targetModule`, re-writing any TypeReference/MethodReference that
    // points at the helper's own mscorlib so it points at the target's
    // existing mscorlib reference instead (same version, so this is a 1:1
    // identity swap, not a compat shim).
    static Dictionary<MetadataToken, object> cloneMap = new Dictionary<MetadataToken, object>();

    static AssemblyNameReference targetMscorlib;

    static TypeReference Retarget(ModuleDefinition targetModule, TypeReference tr)
    {
        if (tr == null) return null;
        if (tr.IsArray)
        {
            var at = (ArrayType)tr;
            return new ArrayType(Retarget(targetModule, at.ElementType), at.Rank);
        }
        if (tr.IsByReference)
        {
            var rt = (ByReferenceType)tr;
            return new ByReferenceType(Retarget(targetModule, rt.ElementType));
        }
        if (tr.Scope != null && tr.Scope.Name == "mscorlib")
        {
            if (tr.Namespace == "System")
            {
                var ts = targetModule.TypeSystem;
                switch (tr.Name)
                {
                    case "Void": return ts.Void;
                    case "Object": return ts.Object;
                    case "Boolean": return ts.Boolean;
                    case "Char": return ts.Char;
                    case "SByte": return ts.SByte;
                    case "Byte": return ts.Byte;
                    case "Int16": return ts.Int16;
                    case "UInt16": return ts.UInt16;
                    case "Int32": return ts.Int32;
                    case "UInt32": return ts.UInt32;
                    case "Int64": return ts.Int64;
                    case "UInt64": return ts.UInt64;
                    case "Single": return ts.Single;
                    case "Double": return ts.Double;
                    case "String": return ts.String;
                    case "IntPtr": return ts.IntPtr;
                    case "UIntPtr": return ts.UIntPtr;
                }
            }
            var newRef = new TypeReference(tr.Namespace, tr.Name, targetModule, targetMscorlib, tr.IsValueType);
            return newRef;
        }
        // Anything else unexpected - fail loudly rather than silently produce a bad module.
        throw new NotSupportedException("Unhandled scope for retarget: " + tr.FullName + " scope=" + tr.Scope);
    }

    static MethodReference RetargetMethodRef(ModuleDefinition targetModule, MethodReference mr)
    {
        var declType = Retarget(targetModule, mr.DeclaringType);
        var newMr = new MethodReference(mr.Name, Retarget(targetModule, mr.ReturnType), declType);
        newMr.HasThis = mr.HasThis;
        newMr.ExplicitThis = mr.ExplicitThis;
        newMr.CallingConvention = mr.CallingConvention;
        foreach (var p in mr.Parameters)
            newMr.Parameters.Add(new ParameterDefinition(p.Name, p.Attributes, Retarget(targetModule, p.ParameterType)));
        return newMr;
    }

    static FieldReference RetargetFieldRef(ModuleDefinition targetModule, FieldReference fr)
    {
        return new FieldReference(fr.Name, Retarget(targetModule, fr.FieldType), Retarget(targetModule, fr.DeclaringType));
    }

    static void CloneMethodBody(ModuleDefinition targetModule, MethodDefinition src, MethodDefinition dst)
    {
        dst.Body.InitLocals = src.Body.InitLocals;
        dst.Body.MaxStackSize = src.Body.MaxStackSize;

        var varMap = new Dictionary<VariableDefinition, VariableDefinition>();
        foreach (var v in src.Body.Variables)
        {
            var nv = new VariableDefinition(Retarget(targetModule, v.VariableType));
            dst.Body.Variables.Add(nv);
            varMap[v] = nv;
        }

        var insnMap = new Dictionary<Instruction, Instruction>();
        var il = dst.Body.GetILProcessor();

        foreach (var i in src.Body.Instructions)
        {
            Instruction ni;
            object operand = i.Operand;

            if (operand is TypeReference tr)
                ni = il.Create(i.OpCode, Retarget(targetModule, tr));
            else if (operand is MethodDefinition selfCallDef)
            {
                if (cloneMap.TryGetValue(selfCallDef.MetadataToken, out var mapped))
                    ni = il.Create(i.OpCode, (MethodReference)mapped);
                else
                    throw new NotSupportedException("call to unmapped local method: " + selfCallDef);
            }
            else if (operand is MethodReference mrf)
                ni = il.Create(i.OpCode, RetargetMethodRef(targetModule, mrf));
            else if (operand is FieldReference frf)
                ni = il.Create(i.OpCode, RetargetFieldRef(targetModule, frf));
            else if (operand is VariableDefinition vd)
                ni = il.Create(i.OpCode, varMap[vd]);
            else if (operand is ParameterDefinition pd)
                ni = il.Create(i.OpCode, dst.Parameters[pd.Index]);
            else if (operand is Instruction target)
                ni = Instruction.Create(i.OpCode, target); // patched below
            else if (operand is Instruction[] targets)
                ni = Instruction.Create(i.OpCode, targets); // patched below
            else if (operand == null)
                ni = il.Create(i.OpCode);
            else
                ni = CreateWithPrimitiveOperand(il, i.OpCode, operand);

            insnMap[i] = ni;
            dst.Body.Instructions.Add(ni);
        }

        // fix up branch targets now that all instructions exist
        for (int idx = 0; idx < src.Body.Instructions.Count; idx++)
        {
            var i = src.Body.Instructions[idx];
            var ni = dst.Body.Instructions[idx];
            if (i.Operand is Instruction singleTarget)
                ni.Operand = insnMap[singleTarget];
            else if (i.Operand is Instruction[] multiTargets)
                ni.Operand = multiTargets.Select(t => insnMap[t]).ToArray();
        }

        foreach (var eh in src.Body.ExceptionHandlers)
        {
            var neh = new ExceptionHandler(eh.HandlerType)
            {
                TryStart = eh.TryStart != null ? insnMap[eh.TryStart] : null,
                TryEnd = eh.TryEnd != null ? insnMap[eh.TryEnd] : null,
                HandlerStart = eh.HandlerStart != null ? insnMap[eh.HandlerStart] : null,
                HandlerEnd = eh.HandlerEnd != null ? insnMap[eh.HandlerEnd] : null,
                FilterStart = eh.FilterStart != null ? insnMap[eh.FilterStart] : null,
                CatchType = eh.CatchType != null ? Retarget(targetModule, eh.CatchType) : null,
            };
            dst.Body.ExceptionHandlers.Add(neh);
        }
    }

    static Instruction CreateWithPrimitiveOperand(ILProcessor il, OpCode op, object operand)
    {
        switch (operand)
        {
            case string s: return il.Create(op, s);
            case sbyte sb: return il.Create(op, sb);
            case byte b: return il.Create(op, b);
            case int i32: return il.Create(op, i32);
            case long i64: return il.Create(op, i64);
            case float f32: return il.Create(op, f32);
            case double f64: return il.Create(op, f64);
            default: throw new NotSupportedException("operand type " + operand.GetType());
        }
    }

    static void Main(string[] args)
    {
        string gameExePath = args[0];
        string bridgeDllPath = args[1];
        string outPath = args[2];

        var readerParams = new ReaderParameters { ReadWrite = false };
        var targetModule = ModuleDefinition.ReadModule(gameExePath);
        targetMscorlib = targetModule.AssemblyReferences.Single(r => r.Name == "mscorlib");

        var bridgeModule = ModuleDefinition.ReadModule(bridgeDllPath);
        var bridgeType = bridgeModule.Types.Single(t => t.Name == "OeVorbisBridge");

        // 0. Idempotency: if this exe was already patched by an earlier run of
        //    this tool, strip the previously-injected bridge type and the
        //    previously-injected FromStream redirect before doing anything
        //    else. Without this, re-running the patcher (e.g. to pick up an
        //    updated bridge) stacks a second type with the same full name
        //    (illegal / undefined behavior for type resolution) and a second
        //    redirect call in FromStream.
        var existingBridge = targetModule.Types.FirstOrDefault(
            t => t.Namespace == bridgeType.Namespace && t.Name == bridgeType.Name);
        if (existingBridge != null)
        {
            Console.WriteLine("Found existing injected type " + existingBridge.FullName + " - removing before re-injecting.");
            targetModule.Types.Remove(existingBridge);
        }

        {
            TypeDefinition existingWaveType = null;
            foreach (var t in targetModule.Types)
                if (t.Name == "OeWaveFileData") { existingWaveType = t; break; }
            if (existingWaveType != null)
            {
                var existingFromStream = existingWaveType.Methods.SingleOrDefault(m => m.Name == "FromStream");
                if (existingFromStream != null && existingFromStream.HasBody)
                {
                    var body = existingFromStream.Body;
                    bool strippedAny = false;
                    while (body.Instructions.Count >= 3 &&
                           body.Instructions[0].OpCode == OpCodes.Ldarg_0 &&
                           body.Instructions[1].OpCode == OpCodes.Call &&
                           body.Instructions[1].Operand is MethodReference callee &&
                           callee.Name == "TryConvertOggToWav" &&
                           body.Instructions[2].OpCode == OpCodes.Starg_S)
                    {
                        body.Instructions.RemoveAt(0);
                        body.Instructions.RemoveAt(0);
                        body.Instructions.RemoveAt(0);
                        strippedAny = true;
                    }
                    if (strippedAny)
                        Console.WriteLine("Stripped previously-injected redirect from FromStream.");
                }
            }
        }

        // 1. Create the shell type + method signatures first, so cross-method
        //    calls (there are none here, but keep it general) can resolve.
        var newType = new TypeDefinition(
            bridgeType.Namespace, bridgeType.Name,
            TypeAttributes.Public | TypeAttributes.Abstract | TypeAttributes.Sealed | TypeAttributes.Class,
            Retarget(targetModule, bridgeModule.TypeSystem.Object));
        targetModule.Types.Add(newType);

        var methodDefs = new Dictionary<MethodDefinition, MethodDefinition>();
        foreach (var m in bridgeType.Methods)
        {
            var nm = new MethodDefinition(m.Name, m.Attributes, Retarget(targetModule, m.ReturnType));
            nm.ImplAttributes = m.ImplAttributes;
            nm.HasThis = !m.IsStatic;
            foreach (var p in m.Parameters)
                nm.Parameters.Add(new ParameterDefinition(p.Name, p.Attributes, Retarget(targetModule, p.ParameterType)));

            if (m.IsPInvokeImpl)
            {
                var modRefName = m.PInvokeInfo.Module.Name;
                var modRef = targetModule.ModuleReferences.FirstOrDefault(mr => mr.Name == modRefName);
                if (modRef == null)
                {
                    modRef = new ModuleReference(modRefName);
                    targetModule.ModuleReferences.Add(modRef);
                }
                nm.PInvokeInfo = new PInvokeInfo(m.PInvokeInfo.Attributes, m.PInvokeInfo.EntryPoint, modRef);
                nm.IsPreserveSig = m.IsPreserveSig;
            }

            newType.Methods.Add(nm);
            methodDefs[m] = nm;
            cloneMap[m.MetadataToken] = nm;
        }

        // 2. Now clone bodies (PInvoke methods have none).
        foreach (var m in bridgeType.Methods)
        {
            if (m.IsPInvokeImpl) continue;
            var nm = methodDefs[m];
            nm.Body = new MethodBody(nm);
            CloneMethodBody(targetModule, m, nm);
        }

        Console.WriteLine("Injected type: " + newType.FullName);
        foreach (var m in newType.Methods)
            Console.WriteLine("  " + m);

        // 3. Patch OeWaveFileData.FromStream: redirect the incoming stream
        //    through TryConvertOggToWav before the existing body runs.
        TypeDefinition waveType = null;
        foreach (var t in targetModule.Types)
            if (t.Name == "OeWaveFileData") { waveType = t; break; }

        if (waveType != null)
        {
        var fromStream = waveType.Methods.Single(m => m.Name == "FromStream");
        var bridgeMethod = newType.Methods.Single(m => m.Name == "TryConvertOggToWav");

        var proc = fromStream.Body.GetILProcessor();
        var first = fromStream.Body.Instructions[0];
        var newInsns = new[]
        {
            Instruction.Create(OpCodes.Ldarg_0),
            Instruction.Create(OpCodes.Call, bridgeMethod),
            Instruction.Create(OpCodes.Starg_S, fromStream.Parameters[0]),
        };
        foreach (var ins in newInsns)
            proc.InsertBefore(first, ins);
        }

        targetModule.Write(outPath);
        Console.WriteLine("Wrote " + outPath);
    }
}
