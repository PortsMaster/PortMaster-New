using System;
using System.Collections.Generic;
using System.Linq;
using Mono.Cecil;
using Mono.Cecil.Cil;

class Patcher
{
    static Dictionary<MetadataToken, object> cloneMap = new Dictionary<MetadataToken, object>();
    static Dictionary<TypeDefinition, TypeDefinition> typeCloneMap = new Dictionary<TypeDefinition, TypeDefinition>();
    static Dictionary<string, AssemblyNameReference> targetAsmRefs = new Dictionary<string, AssemblyNameReference>();

    static AssemblyNameReference GetOrAddTargetAssemblyRef(ModuleDefinition targetModule, AssemblyNameReference sourceRef)
    {
        if (targetAsmRefs.TryGetValue(sourceRef.Name, out var existing))
            return existing;

        var found = targetModule.AssemblyReferences.FirstOrDefault(r => r.Name == sourceRef.Name);
        if (found == null)
        {
            found = new AssemblyNameReference(sourceRef.Name, sourceRef.Version)
            {
                PublicKeyToken = sourceRef.PublicKeyToken,
                Culture = sourceRef.Culture,
            };
            targetModule.AssemblyReferences.Add(found);
            Console.WriteLine("  added new assembly reference: " + found.FullName);
        }
        targetAsmRefs[sourceRef.Name] = found;
        return found;
    }

    static TypeReference Retarget(ModuleDefinition targetModule, TypeReference tr)
    {
        if (tr == null) return null;

        // A reference to a type that is itself being cloned into the target
        // module in this same pass (either a self-reference within one
        // injected type, e.g. a field's declaring type, or a cross-reference
        // between two injected types, e.g. OeMusicStreamInstance calling
        // OeVorbisBridge) resolves straight to the already-created shell
        // type rather than through the assembly-reference machinery below,
        // which only handles references to genuinely external assemblies.
        if (tr is TypeDefinition tdSelf && typeCloneMap.TryGetValue(tdSelf, out var mappedSelf))
            return mappedSelf;

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
        if (tr.Scope is AssemblyNameReference sourceAsmRef)
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
            var targetRef = GetOrAddTargetAssemblyRef(targetModule, sourceAsmRef);
            var newRef = new TypeReference(tr.Namespace, tr.Name, targetModule, targetRef, tr.IsValueType);
            return newRef;
        }
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
                ni = Instruction.Create(i.OpCode, target);
            else if (operand is Instruction[] targets)
                ni = Instruction.Create(i.OpCode, targets);
            else if (operand == null)
                ni = il.Create(i.OpCode);
            else
                ni = CreateWithPrimitiveOperand(il, i.OpCode, operand);

            insnMap[i] = ni;
            dst.Body.Instructions.Add(ni);
        }

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

    static TypeDefinition FindType(ModuleDefinition m, string name)
    {
        foreach (var t in m.Types)
            if (t.Name == name) return t;
        throw new Exception("Type not found: " + name);
    }

    static MethodReference FindMatchingMethod(TypeDefinition t, MethodReference orig)
    {
        foreach (var m in t.Methods)
            if (m.Name == orig.Name && m.Parameters.Count == orig.Parameters.Count)
                return m;
        throw new Exception("No matching method " + orig.Name + "/" + orig.Parameters.Count + " on " + t.FullName);
    }

    // Clones every type in `bridgeModule` (skipping <Module>) into `targetModule`,
    // handling cross-references between the cloned types themselves as well as
    // to the target's existing external assembly references.
    static void InjectTypes(ModuleDefinition targetModule, ModuleDefinition bridgeModule, List<TypeDefinition> injected)
    {
        var sourceTypes = bridgeModule.Types.Where(t => t.Name != "<Module>").ToList();

        // Remove any previously-injected copies (idempotency across repeated runs).
        foreach (var st in sourceTypes)
        {
            var existing = targetModule.Types.FirstOrDefault(t => t.Namespace == st.Namespace && t.Name == st.Name);
            if (existing != null)
            {
                Console.WriteLine("Found existing injected type " + existing.FullName + " - removing before re-injecting.");
                targetModule.Types.Remove(existing);
            }
        }

        // Phase 1: shell types + fields + method signatures for ALL source
        // types first, so any cross-type/self-type reference encountered
        // while cloning bodies later (phase 2) already resolves.
        var newTypes = new Dictionary<TypeDefinition, TypeDefinition>();
        foreach (var st in sourceTypes)
        {
            var attrs = TypeAttributes.Public | TypeAttributes.Class |
                        (st.IsAbstract ? TypeAttributes.Abstract : 0) |
                        (st.IsSealed ? TypeAttributes.Sealed : 0);
            var newType = new TypeDefinition(st.Namespace, st.Name, attrs,
                Retarget(targetModule, st.BaseType));
            targetModule.Types.Add(newType);
            newTypes[st] = newType;
            typeCloneMap[st] = newType;
        }

        foreach (var st in sourceTypes)
        {
            var newType = newTypes[st];

            foreach (var f in st.Fields)
            {
                var nf = new FieldDefinition(f.Name, f.Attributes, Retarget(targetModule, f.FieldType));
                if (f.HasConstant)
                    nf.Constant = f.Constant;
                newType.Fields.Add(nf);
            }

            var methodDefs = new Dictionary<MethodDefinition, MethodDefinition>();
            foreach (var m in st.Methods)
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

            // stash for phase 2
            perTypeMethodDefs[st] = methodDefs;
        }

        // Phase 2: clone bodies now that every type/field/method signature
        // that could be referenced already exists.
        foreach (var st in sourceTypes)
        {
            var methodDefs = perTypeMethodDefs[st];
            foreach (var m in st.Methods)
            {
                if (m.IsPInvokeImpl) continue;
                var nm = methodDefs[m];
                nm.Body = new MethodBody(nm);
                CloneMethodBody(targetModule, m, nm);
            }
        }

        foreach (var st in sourceTypes)
        {
            Console.WriteLine("Injected type: " + newTypes[st].FullName);
            foreach (var m in newTypes[st].Methods)
                Console.WriteLine("  " + m);
            injected.Add(newTypes[st]);
        }
    }

    static Dictionary<TypeDefinition, Dictionary<MethodDefinition, MethodDefinition>> perTypeMethodDefs =
        new Dictionary<TypeDefinition, Dictionary<MethodDefinition, MethodDefinition>>();

    static void Main(string[] args)
    {
        string gameExePath = args[0];
        string bridgeDllPath = args[1];
        string outPath = args[2];

        var targetModule = ModuleDefinition.ReadModule(gameExePath);
        var bridgeModule = ModuleDefinition.ReadModule(bridgeDllPath);

        // 1/2. Inject OeVorbisBridge (extended) + new OeMusicStreamInstance.
        var injected = new List<TypeDefinition>();
        InjectTypes(targetModule, bridgeModule, injected);

        var bridgeType = injected.Single(t => t.Name == "OeVorbisBridge");
        var streamType = injected.Single(t => t.Name == "OeMusicStreamInstance");

        // 3. Patch OeWaveFileData.FromStream: redirect the incoming stream
        //    through TryConvertOggToWav before the existing body runs. Same
        //    redirect as before (used by SFX and by anything still going
        //    through the WaveFileData path); idempotency-stripped first so
        //    re-running this tool doesn't stack a second redirect.
        var waveType = FindType(targetModule, "OeWaveFileData");
        {
            var fromStream = waveType.Methods.Single(m => m.Name == "FromStream");
            var body = fromStream.Body;
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
            }

            var bridgeMethod = bridgeType.Methods.Single(m => m.Name == "TryConvertOggToWav");
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

        // 4. OeMusic: add a lightweight file-path-based construction path
        //    that music now uses instead of eagerly decoding the whole
        //    track. The old OeWaveFileData/SoundEffect ctors, fields and
        //    getters are left in place, unused, rather than removed, to
        //    keep this a pure-addition change on that type.
        var musicType = FindType(targetModule, "OeMusic");
        var resourceDataType = FindType(targetModule, "OeResourceData");
        var stringType = targetModule.TypeSystem.String;
        var voidType = targetModule.TypeSystem.Void;

        var filePathField = new FieldDefinition("_mFilePath", FieldAttributes.Private, stringType);
        musicType.Fields.Add(filePathField);

        var resourceDataCtor = resourceDataType.Methods.Single(m => m.Name == ".ctor" && m.Parameters.Count == 0);

        var pathCtor = new MethodDefinition(".ctor",
            MethodAttributes.Public | MethodAttributes.SpecialName | MethodAttributes.RTSpecialName | MethodAttributes.HideBySig,
            voidType);
        pathCtor.Parameters.Add(new ParameterDefinition("filePath", ParameterAttributes.None, stringType));
        pathCtor.Body = new MethodBody(pathCtor);
        pathCtor.Body.MaxStackSize = 8;
        {
            var il = pathCtor.Body.GetILProcessor();
            il.Emit(OpCodes.Ldarg_0);
            il.Emit(OpCodes.Call, resourceDataCtor);
            il.Emit(OpCodes.Ldarg_0);
            il.Emit(OpCodes.Ldarg_1);
            il.Emit(OpCodes.Stfld, filePathField);
            il.Emit(OpCodes.Ret);
        }
        musicType.Methods.Add(pathCtor);

        var getFilePath = new MethodDefinition("GetFilePath",
            MethodAttributes.Public | MethodAttributes.HideBySig, stringType);
        getFilePath.Body = new MethodBody(getFilePath);
        getFilePath.Body.MaxStackSize = 8;
        {
            var il = getFilePath.Body.GetILProcessor();
            il.Emit(OpCodes.Ldarg_0);
            il.Emit(OpCodes.Ldfld, filePathField);
            il.Emit(OpCodes.Ret);
        }
        musicType.Methods.Add(getFilePath);

        // Replace FromStream's body outright: no more eager decode of any
        // kind for music - just remember the path.
        {
            var fromStream = musicType.Methods.Single(m => m.Name == "FromStream" && m.Parameters.Count == 3);
            fromStream.Body = new MethodBody(fromStream);
            fromStream.Body.MaxStackSize = 8;
            var il = fromStream.Body.GetILProcessor();
            il.Emit(OpCodes.Ldarg_1); // filePath
            il.Emit(OpCodes.Newobj, pathCtor);
            il.Emit(OpCodes.Ret);
        }

        // 5. OeMusicInstance: retarget its playback field from
        //    OeSoundEffectInstance (shared with SFX) to the new
        //    music-only streaming type.
        var musicInstanceType = FindType(targetModule, "OeMusicInstance");
        var currentField = musicInstanceType.Fields.Single(f => f.Name == "_mCurrentMusicInstance");
        currentField.FieldType = streamType;

        // ctor: newobj OeSoundEffectInstance::.ctor() -> newobj OeMusicStreamInstance::.ctor()
        {
            var ctor = musicInstanceType.Methods.Single(m => m.Name == ".ctor" && m.Parameters.Count == 0);
            var newStreamCtor = streamType.Methods.Single(m => m.Name == ".ctor" && m.Parameters.Count == 0);
            foreach (var insn in ctor.Body.Instructions)
            {
                if (insn.OpCode == OpCodes.Newobj && insn.Operand is MethodReference mrNew &&
                    mrNew.DeclaringType.Name == "OeSoundEffectInstance")
                    insn.Operand = newStreamCtor;
            }
        }

        // Play(): the one call site with a genuinely different signature -
        // Setup(string, SoundEffect, OeWaveFileData) -> Setup(string, string).
        // Original sequence around the call:
        //   ldarg.0; ldfld _mCurrentMusicInstance; ldarg.1;
        //   ldloc.0; callvirt OeMusic::GetSoundEffect();
        //   ldloc.0; callvirt OeMusic::GetWaveFileData();
        //   callvirt OeSoundEffectInstance::Setup(string,SoundEffect,OeWaveFileData)
        // becomes:
        //   ldarg.0; ldfld _mCurrentMusicInstance; ldarg.1;
        //   ldloc.0; callvirt OeMusic::GetFilePath();
        //   callvirt OeMusicStreamInstance::Setup(string,string)
        {
            var playMethod = musicInstanceType.Methods.Single(m => m.Name == "Play" && m.Parameters.Count == 4);
            var instrs = playMethod.Body.Instructions;
            int setupIdx = -1;
            for (int i = 0; i < instrs.Count; i++)
            {
                if (instrs[i].OpCode == OpCodes.Callvirt && instrs[i].Operand is MethodReference mr &&
                    mr.DeclaringType.Name == "OeSoundEffectInstance" && mr.Name == "Setup")
                {
                    setupIdx = i;
                    break;
                }
            }
            if (setupIdx < 0) throw new Exception("Could not find Setup call in OeMusicInstance.Play");

            var setupInsn = instrs[setupIdx];
            var getWaveFileDataInsn = instrs[setupIdx - 1];
            var ldloc0BeforeF = instrs[setupIdx - 2];
            var getSoundEffectInsn = instrs[setupIdx - 3];
            var ldloc0BeforeD = instrs[setupIdx - 4];

            if (!(getWaveFileDataInsn.Operand is MethodReference gwfd && gwfd.Name == "GetWaveFileData"))
                throw new Exception("unexpected IL shape before Setup call (GetWaveFileData)");
            if (!(getSoundEffectInsn.Operand is MethodReference gse && gse.Name == "GetSoundEffect"))
                throw new Exception("unexpected IL shape before Setup call (GetSoundEffect)");
            if (ldloc0BeforeD.OpCode != OpCodes.Ldloc_0 || ldloc0BeforeF.OpCode != OpCodes.Ldloc_0)
                throw new Exception("unexpected IL shape before Setup call (ldloc.0)");

            var proc = playMethod.Body.GetILProcessor();
            proc.Remove(ldloc0BeforeD);
            proc.Remove(getSoundEffectInsn);

            getWaveFileDataInsn.Operand = getFilePath;
            setupInsn.Operand = streamType.Methods.Single(m => m.Name == "Setup");
        }

        // Update(): the original tail of OeMusicInstance.Update() was
        //
        //   ldarg.0; ldfld _mCurrentMusicInstance; ldc.i4.1 (isMusic);
        //   callvirt OeSoundEffectInstance::Update(bool)
        //
        // and the first thing OeSoundEffectInstance.Update(bool) did was
        // `if (!_mIsSetup) return;`. Only AFTER that guard did the dynamic
        // instance call OeGameStateManager.ActiveGameState.IsRewinding().
        //
        // The streaming instance needs `isReversing` as an ARGUMENT, so the
        // previous version of this patcher evaluated
        // get_ActiveGameState().IsRewinding() at the call site, i.e. before
        // entering Update(bool) and before any "is anything playing?" guard.
        // OeGameLoader pumps OeMusic.Tick() every frame during loading, when
        // OeGameStateManager.GameStates is still null (it is allocated by the
        // "LoadGameStates" loading job), so get_ActiveGameState()'s
        // `GameStates[_mCurrentGameState]` (ldelem.ref) threw a
        // NullReferenceException from inside the getter itself. Null-checking
        // the getter's RETURN value cannot help; the call must not happen.
        //
        // Fix: move the whole thing into a helper, OeMusicInstance.
        // UpdateStreamInstance(), that reproduces the original ordering:
        //
        //   1. if (!stream.IsSetup) return;               // the old _mIsSetup guard
        //   2. look up the active OeGameState WITHOUT going through the
        //      throwing getter (GameStates null / index out of range /
        //      element null  ->  treat as "not rewinding")
        //   3. if (rewinding && !IsThereAnyRewindTimeRemaining()) return;
        //                                                 // was in the old dynamic Update
        //   4. stream.Update(rewinding)
        //
        // Update()'s tail is then rewritten IN PLACE to `ldarg.0; call
        // UpdateStreamInstance()` so the existing `br.s IL_0040` branches out
        // of the fade-state switch (which target that ldarg.0) stay valid.
        {
            var updateMethod = musicInstanceType.Methods.Single(m => m.Name == "Update" && m.Parameters.Count == 0);

            if (musicInstanceType.Methods.Any(m => m.Name == "UpdateStreamInstance"))
                throw new Exception("OeMusicInstance.UpdateStreamInstance already exists - this looks like an already-patched input. Run the patcher on the ORIGINAL MuteCrimsonDX.dll.");

            var uInstrs = updateMethod.Body.Instructions;
            int updCallIdx = -1;
            for (int i = 0; i < uInstrs.Count; i++)
            {
                if ((uInstrs[i].OpCode == OpCodes.Call || uInstrs[i].OpCode == OpCodes.Callvirt) &&
                    uInstrs[i].Operand is MethodReference mr &&
                    mr.DeclaringType.Name == "OeSoundEffectInstance" && mr.Name == "Update")
                {
                    updCallIdx = i;
                    break;
                }
            }
            if (updCallIdx < 3) throw new Exception("Could not find Update(bool) call in OeMusicInstance.Update");

            var updateCallInsn = uInstrs[updCallIdx];
            var ldc1 = uInstrs[updCallIdx - 1];
            var ldfldInst = uInstrs[updCallIdx - 2];
            var ldarg0 = uInstrs[updCallIdx - 3];
            if (ldc1.OpCode != OpCodes.Ldc_I4_1)
                throw new Exception("unexpected IL shape before Update call (ldc.i4.1)");
            if (!(ldfldInst.OpCode == OpCodes.Ldfld && ldfldInst.Operand is FieldReference fInst && fInst.Name == "_mCurrentMusicInstance"))
                throw new Exception("unexpected IL shape before Update call (ldfld _mCurrentMusicInstance)");
            if (ldarg0.OpCode != OpCodes.Ldarg_0)
                throw new Exception("unexpected IL shape before Update call (ldarg.0)");
            if (uInstrs[updCallIdx + 1].OpCode != OpCodes.Ret)
                throw new Exception("unexpected IL shape after Update call (ret)");

            var gsmType = FindType(targetModule, "OeGameStateManager");
            var gameStatesField = gsmType.Fields.Single(f => f.Name == "GameStates");
            var getCurrentGameState = gsmType.Methods.Single(m => m.Name == "GetCurrentGameState");
            var gameStateType = FindType(targetModule, "OeGameState");
            var isRewinding = gameStateType.Methods.Single(m => m.Name == "IsRewinding");
            var isThereRewindTime = gameStateType.Methods.Single(m => m.Name == "IsThereAnyRewindTimeRemaining");
            var streamIsSetup = streamType.Methods.Single(m => m.Name == "get_IsSetup");
            var streamUpdate = streamType.Methods.Single(m => m.Name == "Update");

            var helper = new MethodDefinition("UpdateStreamInstance",
                MethodAttributes.Private | MethodAttributes.HideBySig, voidType);
            helper.Body = new MethodBody(helper);
            helper.Body.InitLocals = true;
            helper.Body.MaxStackSize = 8;

            var vStates = new VariableDefinition(new ArrayType(gameStateType));
            var vGs = new VariableDefinition(gameStateType);
            var vIdx = new VariableDefinition(targetModule.TypeSystem.Int32);
            var vRewinding = new VariableDefinition(targetModule.TypeSystem.Boolean);
            helper.Body.Variables.Add(vStates);
            helper.Body.Variables.Add(vGs);
            helper.Body.Variables.Add(vIdx);
            helper.Body.Variables.Add(vRewinding);

            var il = helper.Body.GetILProcessor();
            var lookupStart = Instruction.Create(OpCodes.Ldnull);
            var afterLookup = Instruction.Create(OpCodes.Ldloc, vGs);
            var callUpdate = Instruction.Create(OpCodes.Ldarg_0);

            // OeVorbisBridge.Heartbeat();   (diagnostic memory line, ~every 2 s)
            il.Emit(OpCodes.Call, bridgeType.Methods.Single(m => m.Name == "Heartbeat"));

            // if (!_mCurrentMusicInstance.IsSetup) return;
            il.Emit(OpCodes.Ldarg_0);
            il.Emit(OpCodes.Ldfld, currentField);
            il.Emit(OpCodes.Callvirt, streamIsSetup);
            il.Emit(OpCodes.Brtrue, lookupStart);
            il.Emit(OpCodes.Ret);

            // gs = null; rewinding = false; states = GameStates;
            il.Append(lookupStart);
            il.Emit(OpCodes.Stloc, vGs);
            il.Emit(OpCodes.Ldc_I4_0);
            il.Emit(OpCodes.Stloc, vRewinding);
            il.Emit(OpCodes.Ldsfld, gameStatesField);
            il.Emit(OpCodes.Stloc, vStates);

            // if (states != null) { idx = GetCurrentGameState(); if ((uint)idx < (uint)states.Length) gs = states[idx]; }
            il.Emit(OpCodes.Ldloc, vStates);
            il.Emit(OpCodes.Brfalse, afterLookup);
            il.Emit(OpCodes.Call, getCurrentGameState);
            il.Emit(OpCodes.Stloc, vIdx);
            il.Emit(OpCodes.Ldloc, vIdx);
            il.Emit(OpCodes.Ldloc, vStates);
            il.Emit(OpCodes.Ldlen);
            il.Emit(OpCodes.Conv_I4);
            il.Emit(OpCodes.Bge_Un, afterLookup);
            il.Emit(OpCodes.Ldloc, vStates);
            il.Emit(OpCodes.Ldloc, vIdx);
            il.Emit(OpCodes.Ldelem_Ref);
            il.Emit(OpCodes.Stloc, vGs);

            // if (gs != null) { rewinding = gs.IsRewinding(); if (rewinding && !gs.IsThereAnyRewindTimeRemaining()) return; }
            il.Append(afterLookup);                       // ldloc gs
            il.Emit(OpCodes.Brfalse, callUpdate);
            il.Emit(OpCodes.Ldloc, vGs);
            il.Emit(OpCodes.Callvirt, isRewinding);
            il.Emit(OpCodes.Stloc, vRewinding);
            il.Emit(OpCodes.Ldloc, vRewinding);
            il.Emit(OpCodes.Brfalse, callUpdate);
            il.Emit(OpCodes.Ldloc, vGs);
            il.Emit(OpCodes.Callvirt, isThereRewindTime);
            il.Emit(OpCodes.Brtrue, callUpdate);
            il.Emit(OpCodes.Ret);

            // _mCurrentMusicInstance.Update(rewinding);
            il.Append(callUpdate);                        // ldarg.0
            il.Emit(OpCodes.Ldfld, currentField);
            il.Emit(OpCodes.Ldloc, vRewinding);
            il.Emit(OpCodes.Callvirt, streamUpdate);
            il.Emit(OpCodes.Ret);

            musicInstanceType.Methods.Add(helper);

            // Rewrite the tail of Update() in place: keep `ldarg.0` (branch
            // target), turn `ldfld _mCurrentMusicInstance` into
            // `call UpdateStreamInstance`, drop `ldc.i4.1` + `callvirt Update`.
            ldfldInst.OpCode = OpCodes.Call;
            ldfldInst.Operand = helper;
            var uproc = updateMethod.Body.GetILProcessor();
            uproc.Remove(ldc1);
            uproc.Remove(updateCallInsn);
        }

        // 6. Blanket-retarget every remaining same-signature call from
        //    OeSoundEffectInstance to the new type (Play, Pause, Resume,
        //    Stop, get_State, get_Volume, set_Volume, get_IsLooped,
        //    set_IsLooped - everywhere else _mCurrentMusicInstance is used).
        var handledAlready = new HashSet<string> { "Setup" }; // Update(bool) no longer appears here: its call site now lives in UpdateStreamInstance
        foreach (var m in musicInstanceType.Methods)
        {
            if (!m.HasBody) continue;
            foreach (var insn in m.Body.Instructions)
            {
                if ((insn.OpCode == OpCodes.Call || insn.OpCode == OpCodes.Callvirt) &&
                    insn.Operand is MethodReference mr &&
                    mr.DeclaringType.Name == "OeSoundEffectInstance" &&
                    !handledAlready.Contains(mr.Name))
                {
                    insn.Operand = FindMatchingMethod(streamType, mr);
                }
            }
        }

        // Sanity: nothing in OeMusicInstance may still reference the shared
        // OeSoundEffectInstance type; if it does, some call site was missed
        // and would fail at runtime.
        foreach (var m in musicInstanceType.Methods)
        {
            if (!m.HasBody) continue;
            foreach (var insn in m.Body.Instructions)
            {
                if (insn.Operand is MemberReference mref && mref.DeclaringType != null &&
                    mref.DeclaringType.Name == "OeSoundEffectInstance")
                    throw new Exception("Leftover OeSoundEffectInstance reference in OeMusicInstance." + m.Name + ": " + insn);
            }
        }

        // 7. Sprite atlas support for shrinking sheet.png/sheet2.png by 2x
        //    linearly, to cut decoded texture RAM. See OeAtlasRectHelper.cs
        //    for the full reasoning; in short, OeSheet.mRectangle keeps
        //    reporting original-scale coordinates (lots of game code does
        //    its own math on them), and the real half-scale values are
        //    substituted in only at the five places OeSheet hands a draw to
        //    OeSpriteBatch, and ONLY when the sheet really lives in a shrunk
        //    atlas - OeSheet also serves sheets built from standalone,
        //    unshrunk textures (backgrounds, cutscene stills, tilesets), and
        //    an earlier version of this patch scaled those too.
        var sheetType = FindType(targetModule, "OeSheet");
        var helperType = injected.Single(t => t.Name == "OeAtlasRectHelper");
        MethodDefinition H(string n) { return helperType.Methods.Single(m => m.Name == n); }
        var isShrunkAtlas = H("IsShrunkAtlas");
        var halveIf = H("HalveIf");
        var doubleIf = H("DoubleIf");
        var halveIfV2 = H("HalveIfV2");
        var shiftIf = H("ShiftIf");
        var underlyingNameField = sheetType.Fields.Single(f => f.Name == "mUnderlyingTextureName");

        // Instruction lookup helpers (backward from the OeSpriteBatch call).
        int FindCall(Mono.Collections.Generic.Collection<Instruction> ins, string callee)
        {
            for (int i = 0; i < ins.Count; i++)
                if (ins[i].OpCode == OpCodes.Callvirt && ins[i].Operand is MethodReference mr &&
                    mr.DeclaringType.Name == "OeSpriteBatch" && mr.Name == callee) return i;
            throw new Exception("call to OeSpriteBatch::" + callee + " not found");
        }
        bool IsNewV2(Instruction i, int nargs) =>
            i.OpCode == OpCodes.Newobj && i.Operand is MethodReference m &&
            m.DeclaringType.Name == "Vector2" && m.Parameters.Count == nargs;
        int PrevNewV2(Mono.Collections.Generic.Collection<Instruction> ins, int from, int nargs)
        {
            for (int i = from; i >= 0; i--) if (IsNewV2(ins[i], nargs)) return i;
            throw new Exception("Vector2 newobj not found");
        }

        void Expect(bool cond, string what, MethodDefinition m)
        {
            if (!cond) throw new Exception("unexpected IL shape (" + what + ") in " + m.FullName);
        }

        // Transforms one OeSheet -> OeSpriteBatch hand-off.
        //   kind: "draw"        - Draw / DrawInterpolated (scale is a Vector2 param, rect = ldloc.0, origin = param)
        //         "srcrect"     - DrawSourceRect (scale float -> Vector2 newobj, rect = ldarg sourceRectangle, origin = param)
        //         "srcrectint"  - DrawSourceRectInterpolated (origin built inline from sourceRectangle)
        //         "destrect"    - DrawDestinationRect (flush ignores origin/scale: rect only)
        void PatchHandoff(MethodDefinition method, string callee, string kind)
        {
            var body = method.Body;
            var ins = body.Instructions;
            var proc = body.GetILProcessor();

            // atlas = IsShrunkAtlas(sheet.mUnderlyingTextureName), computed once at entry.
            var atlasLocal = new VariableDefinition(targetModule.TypeSystem.Boolean);
            body.Variables.Add(atlasLocal);
            var first = ins[0];
            proc.InsertBefore(first, Instruction.Create(OpCodes.Ldarg_0));
            proc.InsertBefore(first, Instruction.Create(OpCodes.Ldfld, underlyingNameField));
            proc.InsertBefore(first, Instruction.Create(OpCodes.Call, isShrunkAtlas));
            proc.InsertBefore(first, Instruction.Create(OpCodes.Stloc, atlasLocal));

            Instruction Atlas() { return Instruction.Create(OpCodes.Ldloc, atlasLocal); }
            void After(Instruction target, MethodDefinition helper)
            {
                proc.InsertAfter(target, Instruction.Create(OpCodes.Call, helper));
                proc.InsertAfter(target, Atlas());
            }
            ParameterDefinition P(string n) { return method.Parameters.Single(p => p.Name == n); }

            int callIdx = FindCall(ins, callee);
            var call = ins[callIdx];

            if (kind == "draw")
            {
                Expect(ins[callIdx - 1].OpCode == OpCodes.Ldarg_S && ((ParameterDefinition)ins[callIdx - 1].Operand).Name == "origin", "origin", method);
                Expect(ins[callIdx - 5].OpCode == OpCodes.Ldarg_S && ((ParameterDefinition)ins[callIdx - 5].Operand).Name == "scale", "scale", method);
                Expect(ins[callIdx - 6].OpCode == OpCodes.Ldloc_0, "rect", method);
                var origin = ins[callIdx - 1];
                var scale = ins[callIdx - 5];
                var rect = ins[callIdx - 6];
                // For DrawInterpolated there are two positions (position, lastPosition), each a Vector2(float,float) newobj.
                var positions = new System.Collections.Generic.List<Instruction>();
                if (callee == "DrawInterpolated")
                {
                    int last = callIdx - 7; Expect(IsNewV2(ins[last], 2), "lastPosition", method);
                    int prev = PrevNewV2(ins, last - 1, 2);
                    positions.Add(ins[prev]); positions.Add(ins[last]);
                }
                else
                {
                    Expect(IsNewV2(ins[callIdx - 7], 2), "position", method);
                    positions.Add(ins[callIdx - 7]);
                }

                // Apply back-to-front so earlier references stay valid.
                After(origin, halveIfV2);
                After(scale, doubleIf);
                After(rect, halveIf);
                for (int k = positions.Count - 1; k >= 0; k--)
                {
                    var pos = positions[k];
                    proc.InsertAfter(pos, Instruction.Create(OpCodes.Call, shiftIf));
                    proc.InsertAfter(pos, Atlas());
                    proc.InsertAfter(pos, Instruction.Create(OpCodes.Ldarg_S, P("origin")));
                }
            }
            else if (kind == "srcrect")
            {
                Expect(ins[callIdx - 1].OpCode == OpCodes.Ldarg_S && ((ParameterDefinition)ins[callIdx - 1].Operand).Name == "origin", "origin", method);
                Expect(IsNewV2(ins[callIdx - 5], 1), "scale newobj", method);
                Expect(ins[callIdx - 7].OpCode == OpCodes.Ldarg_S && ((ParameterDefinition)ins[callIdx - 7].Operand).Name == "sourceRectangle", "rect", method);
                Expect(IsNewV2(ins[callIdx - 8], 2), "position", method);
                var origin = ins[callIdx - 1]; var scaleV = ins[callIdx - 5];
                var rect = ins[callIdx - 7]; var pos = ins[callIdx - 8];
                After(origin, halveIfV2);
                After(scaleV, doubleIf);
                After(rect, halveIf);
                proc.InsertAfter(pos, Instruction.Create(OpCodes.Call, shiftIf));
                proc.InsertAfter(pos, Atlas());
                proc.InsertAfter(pos, Instruction.Create(OpCodes.Ldarg_S, P("origin")));
            }
            else if (kind == "srcrectint")
            {
                // origin is built inline as Vector2(sourceRectangle.Width/2, sourceRectangle.Height/2) - the last pushed arg.
                Expect(IsNewV2(ins[callIdx - 1], 2), "inline origin", method);
                int scaleNew = PrevNewV2(ins, callIdx - 2, 1); // the Vector2(float) scale newobj (the inline origin uses the 2-arg ctor)
                Expect(ins[scaleNew - 2].OpCode == OpCodes.Ldarg_S && ((ParameterDefinition)ins[scaleNew - 2].Operand).Name == "sourceRectangle", "rect", method);
                int lastPosIdx = scaleNew - 3; Expect(IsNewV2(ins[lastPosIdx], 2), "lastPosition", method);
                int posIdx = PrevNewV2(ins, lastPosIdx - 1, 2);
                var origin = ins[callIdx - 1]; var scaleV = ins[scaleNew]; var rect = ins[scaleNew - 2];
                var lastPos = ins[lastPosIdx]; var pos = ins[posIdx];
                // Snapshot the inline-origin instruction run (from the first ldarg.s sourceRectangle after rotation/flips to origin newobj)
                int originStart = -1;
                for (int i = callIdx - 2; i > scaleNew; i--)
                    if (ins[i].OpCode == OpCodes.Ldarg_S && ((ParameterDefinition)ins[i].Operand).Name == "sourceRectangle" &&
                        ins[i + 1].OpCode == OpCodes.Ldfld && ((FieldReference)ins[i + 1].Operand).Name == "Width") originStart = i;
                Expect(originStart > 0, "inline origin start", method);
                var originRun = new System.Collections.Generic.List<Instruction>();
                for (int i = originStart; i <= callIdx - 1; i++) originRun.Add(ins[i]);

                After(origin, halveIfV2);
                After(scaleV, doubleIf);
                After(rect, halveIf);
                foreach (var target in new[] { lastPos, pos })
                {
                    // ... newobj position ; <origin run re-emitted> ; atlas ; ShiftIf
                    Instruction cursor = target;
                    foreach (var o in originRun)
                    {
                        var clone = o.Operand == null ? Instruction.Create(o.OpCode)
                              : o.Operand is FieldReference fr ? Instruction.Create(o.OpCode, fr)
                              : o.Operand is MethodReference mrf ? Instruction.Create(o.OpCode, mrf)
                              : o.Operand is ParameterDefinition pd ? Instruction.Create(o.OpCode, pd)
                              : throw new Exception("unhandled operand in inline origin");
                        proc.InsertAfter(cursor, clone); cursor = clone;
                    }
                    var a1 = Atlas(); proc.InsertAfter(cursor, a1);
                    proc.InsertAfter(a1, Instruction.Create(OpCodes.Call, shiftIf));
                }
            }
            else if (kind == "destrect")
            {
                int rectIdx = -1;
                for (int i = callIdx - 1; i >= 0; i--) if (ins[i].OpCode == OpCodes.Ldloc_0) { rectIdx = i; break; }
                Expect(rectIdx > 0, "rect", method);
                After(ins[rectIdx], halveIf);
            }
            Console.WriteLine("Patched " + method.Name + " (" + kind + ") -> OeSpriteBatch::" + callee);
        }

        MethodDefinition Core(string name, int paramCount, string callee) =>
            sheetType.Methods.Single(m => m.Name == name && m.Parameters.Count == paramCount &&
                                          m.Parameters[0].ParameterType.GetElementType().Name == "OeSheet" &&
                                          m.HasBody && m.Body.Instructions.Any(i => i.OpCode == OpCodes.Callvirt &&
                                              i.Operand is MethodReference mr && mr.DeclaringType.Name == "OeSpriteBatch" && mr.Name == callee));

        PatchHandoff(Core("Draw", 13, "Draw"), "Draw", "draw");
        PatchHandoff(Core("DrawInterpolated", 14, "DrawInterpolated"), "DrawInterpolated", "draw");
        PatchHandoff(Core("DrawDestinationRect", 11, "DrawRectangle"), "DrawRectangle", "destrect");
        PatchHandoff(Core("DrawSourceRect", 13, "Draw"), "Draw", "srcrect");
        PatchHandoff(Core("DrawSourceRectInterpolated", 13, "DrawInterpolated"), "DrawInterpolated", "srcrectint");

        // 7b. OeRenderer's tile-layer draw (compiler-generated local function
        //     '<Commit>g__DrawTiles|11_0') draws ANIMATED tiles (lava, hazards,
        //     conveyor belts, ... placed in tile layers) with a raw
        //     SpriteBatch.Draw that reads OeAnimTile.GetAnimationSheet()'s
        //     mRectangle directly and never goes through OeSheet.Draw*, so the
        //     five hand-off patches above never see it. On a shrunk atlas that
        //     samples an ORIGINAL-scale rect from the half-size texture: the
        //     wrong region, usually much larger than the real sprite - the
        //     "whole tile filled with the wrong sprite" glitch.
        //
        //     Here position is computed as (pos + half) - origin + origin, which
        //     is just pos + half no matter what origin is, so unlike the
        //     OeSheet hand-offs NO position shift is needed: only the source
        //     rect (halve), the origin passed to SpriteBatch.Draw (halve) and
        //     the float scale (x2) change. The wrap branch uses a standalone,
        //     unshrunk texture and is left alone; the placeholder/tileset
        //     branches never touch an atlas.
        {
            var rendererType = FindType(targetModule, "OeRenderer");
            var drawTiles = rendererType.Methods.Single(m => m.Name == "<Commit>g__DrawTiles|11_0");
            var db = drawTiles.Body;
            var dins = db.Instructions;
            var dproc = db.GetILProcessor();

            int getAnim = -1;
            for (int i = 0; i < dins.Count; i++)
                if (dins[i].OpCode == OpCodes.Call && dins[i].Operand is MethodReference gm && gm.Name == "GetAnimationSheet") { getAnim = i; break; }
            if (getAnim < 0) throw new Exception("GetAnimationSheet call not found in DrawTiles");
            var stSheet = dins[getAnim + 1];
            if (stSheet.OpCode != OpCodes.Stloc_S) throw new Exception("unexpected IL after GetAnimationSheet in DrawTiles");
            var sheetVar = (VariableDefinition)stSheet.Operand;

            int sbDraw = -1;
            for (int i = getAnim; i < dins.Count; i++)
                if (dins[i].OpCode == OpCodes.Callvirt && dins[i].Operand is MethodReference dm &&
                    dm.DeclaringType.Name == "SpriteBatch" && dm.Name == "Draw") { sbDraw = i; break; }
            if (sbDraw < 0) throw new Exception("SpriteBatch.Draw not found after GetAnimationSheet in DrawTiles");

            // SpriteBatch.Draw(tex, pos, srcRect?, color, rot, origin, scale, effects, depth), read backwards:
            //   -1 ldc.r4 depth  -2 ldloc effects  -3 conv.r4  -4 ldfld mScaler  -5 ldloc animTile  -6 ldloc origin
            Expect(dins[sbDraw - 1].OpCode == OpCodes.Ldc_R4, "depth", drawTiles);
            Expect(dins[sbDraw - 3].OpCode == OpCodes.Conv_R4, "scale conv", drawTiles);
            Expect(dins[sbDraw - 4].OpCode == OpCodes.Ldfld && ((FieldReference)dins[sbDraw - 4].Operand).Name == "mScaler", "mScaler", drawTiles);
            var originLoad = dins[sbDraw - 6];
            Expect(originLoad.OpCode == OpCodes.Ldloc_S, "origin load", drawTiles);
            var originVar = (VariableDefinition)originLoad.Operand;
            var scaleConv = dins[sbDraw - 3];

            // The source rect is the ldloc just before the Nullable<Rectangle> newobj.
            Instruction rectLoad = null;
            for (int i = getAnim; i < sbDraw; i++)
                if (dins[i].OpCode == OpCodes.Newobj && dins[i].Operand is MethodReference nm &&
                    nm.DeclaringType.Name.StartsWith("Nullable") && dins[i - 1].OpCode == OpCodes.Ldloc_S) { rectLoad = dins[i - 1]; break; }
            Expect(rectLoad != null, "source rect load", drawTiles);
            var rectVar = (VariableDefinition)rectLoad.Operand;
            Expect(rectVar.VariableType.Name == "Rectangle" && originVar.VariableType.Name == "Vector2", "local types", drawTiles);

            var dAtlas = new VariableDefinition(targetModule.TypeSystem.Boolean);
            db.Variables.Add(dAtlas);

            // Back-to-front so earlier instruction references stay valid.
            dproc.InsertAfter(scaleConv, Instruction.Create(OpCodes.Call, H("DoubleIfF")));
            dproc.InsertAfter(scaleConv, Instruction.Create(OpCodes.Ldloc, dAtlas));
            dproc.InsertAfter(originLoad, Instruction.Create(OpCodes.Call, halveIfV2));
            dproc.InsertAfter(originLoad, Instruction.Create(OpCodes.Ldloc, dAtlas));
            dproc.InsertAfter(rectLoad, Instruction.Create(OpCodes.Call, halveIf));
            dproc.InsertAfter(rectLoad, Instruction.Create(OpCodes.Ldloc, dAtlas));

            // atlas = IsShrunkAtlas(sheet.mUnderlyingTextureName), right after the sheet ref is stored.
            dproc.InsertAfter(stSheet, Instruction.Create(OpCodes.Stloc, dAtlas));
            dproc.InsertAfter(stSheet, Instruction.Create(OpCodes.Call, isShrunkAtlas));
            dproc.InsertAfter(stSheet, Instruction.Create(OpCodes.Ldfld, underlyingNameField));
            dproc.InsertAfter(stSheet, Instruction.Create(OpCodes.Ldloc, sheetVar));
            Console.WriteLine("Patched OeRenderer." + drawTiles.Name + " (animated-tile raw SpriteBatch.Draw)");
        }

        // 8. Force an AnyCPU-style header (see original comment for why).
        Console.WriteLine("Rewriting header as AnyCPU (was " + targetModule.Architecture + ")...");
        targetModule.Architecture = TargetArchitecture.I386;
        targetModule.Attributes = ModuleAttributes.ILOnly;

        targetModule.Write(outPath);
        Console.WriteLine("Wrote " + outPath);
    }
}
