using System;using System.Linq;using System.Collections.Generic;
using Mono.Cecil;using Mono.Cecil.Cil;
class P{
 static void Main(string[] a){
  string inp=a[0], outp=a[1]; int perHit=a.Length>2?int.Parse(a[2]):12; int cap=a.Length>3?int.Parse(a[3]):1024;
  var asm=AssemblyDefinition.ReadAssembly(inp,new ReaderParameters{InMemory=true});
  var mod=asm.MainModule;
  var blood=mod.GetTypes().First(t=>t.FullName=="MuteCrimsonDX.CrEffectBlood");
  var draw=blood.Methods.First(m=>m.Name=="DrawRoutine");
  var ins=draw.Body.Instructions;
  // gather refs
  var calls=ins.Where(i=>i.OpCode==OpCodes.Call && i.Operand is MethodReference mr && mr.Name=="DrawTheParticle").ToList();
  if(calls.Count!=3) throw new Exception("DrawRoutine shape: "+calls.Count);
  var getPos=ins.Select(i=>i.Operand).OfType<MethodReference>().First(m=>m.Name=="GetPosition");
  var getLast=ins.Select(i=>i.Operand).OfType<MethodReference>().First(m=>m.Name=="GetLastRenderPosition");
  var fMBody=ins.Select(i=>i.Operand).OfType<FieldReference>().First(f=>f.Name=="mBody");
  var fCur=ins.Select(i=>i.Operand).OfType<FieldReference>().First(f=>f.Name=="mCurrentRenderPosition");
  var fLast=ins.Select(i=>i.Operand).OfType<FieldReference>().First(f=>f.Name=="mLastRenderPosition");
  var v2=getPos.ReturnType;
  // Vector2 X/Y field refs: reuse from existing IL in the module
  FieldReference fX=null,fY=null;
  foreach(var t in mod.GetTypes()) foreach(var m in t.Methods){ if(!m.HasBody)continue; foreach(var i in m.Body.Instructions) if(i.Operand is FieldReference f && f.DeclaringType.FullName=="Microsoft.Xna.Framework.Vector2"){ if(f.Name=="X")fX=f; if(f.Name=="Y")fY=f; } if(fX!=null&&fY!=null)break; if(fX!=null&&fY!=null)break;}
  var dataRef=draw.Parameters[1].ParameterType; // CrEffectBloodData&
  var posField=ins.Select(i=>i.Operand).OfType<FieldReference>().First(f=>f.Name=="mExtraBloodPos0");
  var posRef=new ByReferenceType(posField.FieldType);
  var h=new MethodDefinition("IsSameAsBody",MethodAttributes.Private|MethodAttributes.Static|MethodAttributes.HideBySig,mod.TypeSystem.Boolean);
  h.Parameters.Add(new ParameterDefinition("d",ParameterAttributes.None,dataRef));
  h.Parameters.Add(new ParameterDefinition("p",ParameterAttributes.None,posRef));
  h.Body.Variables.Add(new VariableDefinition(v2));h.Body.Variables.Add(new VariableDefinition(v2));
  h.Body.InitLocals=true;
  var il=h.Body.GetILProcessor();
  var no=il.Create(OpCodes.Ldc_I4_0);
  il.Emit(OpCodes.Ldarg_0);il.Emit(OpCodes.Ldflda,fMBody);il.Emit(OpCodes.Call,getPos);il.Emit(OpCodes.Stloc,h.Body.Variables[0]);
  il.Emit(OpCodes.Ldarg_0);il.Emit(OpCodes.Ldflda,fMBody);il.Emit(OpCodes.Call,getLast);il.Emit(OpCodes.Stloc,h.Body.Variables[1]);
  FieldReference[] flds=new FieldReference[]{fCur,fLast};
  for(int loc=0;loc<2;loc++) foreach(var c in new[]{fX,fY}){
    il.Emit(OpCodes.Ldarg_1);il.Emit(OpCodes.Ldflda,flds[loc]);il.Emit(OpCodes.Ldfld,c);
    il.Emit(OpCodes.Ldloca,h.Body.Variables[loc]);il.Emit(OpCodes.Ldfld,c);
    il.Emit(OpCodes.Bne_Un,no);
  }
  il.Emit(OpCodes.Ldc_I4_1);il.Emit(OpCodes.Ret);il.Append(no);il.Emit(OpCodes.Ret);
  blood.Methods.Add(h);
  var p=draw.Body.GetILProcessor();
  // guard for blocks 2 then 1 (insert before each block's leading dup)
  Action<Instruction> guard=(call)=>{
    // find block start: walk back to the 'dup'
    var s=call; while(s.OpCode!=OpCodes.Dup) s=s.Previous;
    var f=s; while(f!=call){ if(f.Operand is FieldReference fr && fr.Name.StartsWith("mExtraBloodPos")){posField=fr;break;} f=f.Next; }
    var target=call.Next;
    p.InsertBefore(s,Instruction.Create(OpCodes.Ldarg_1));
    p.InsertBefore(s,Instruction.Create(OpCodes.Ldarg_1));
    p.InsertBefore(s,Instruction.Create(OpCodes.Ldflda,posField));
    p.InsertBefore(s,Instruction.Create(OpCodes.Call,h));
    p.InsertBefore(s,Instruction.Create(OpCodes.Brtrue,target));
  };
  guard(calls[1]); guard(calls[0]);
  // cap in Create
  var create=blood.Methods.First(m=>m.Name=="Create");
  int n=0; foreach(var i in create.Body.Instructions) if(i.OpCode==OpCodes.Ldc_I4 && (int)i.Operand==4096){i.Operand=cap;n++;}
  if(n!=2) throw new Exception("cap sites "+n);
  // per-hit count in CrComEnemyKitSys.Bleed
  var kit=mod.GetTypes().First(t=>t.FullName=="MuteCrimsonDX.Components.CrComEnemyKitSys");
  var bleed=kit.Methods.First(m=>m.Name=="Bleed");
  var first=bleed.Body.Instructions.First(i=>i.OpCode==OpCodes.Ldc_I4_S && (sbyte)i.Operand==20);
  first.Operand=(sbyte)perHit;
  asm.Write(outp);
  Console.WriteLine("ok perHit="+perHit+" cap="+cap);
 }}
