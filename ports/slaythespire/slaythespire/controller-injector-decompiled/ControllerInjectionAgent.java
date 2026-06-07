/*     */ package spire.agent;
/*     */ import java.lang.instrument.ClassFileTransformer;
/*     */ import java.lang.instrument.Instrumentation;
/*     */ import javassist.ClassPool;
/*     */ import javassist.CtClass;
/*     */ import javassist.CtConstructor;
/*     */ import javassist.CtMethod;
/*     */ 
/*     */ public class ControllerInjectionAgent {
/*     */   public static void premain(String paramString, Instrumentation paramInstrumentation) {
/*  11 */     System.out.println("[ControllerAgent] ========================================");
/*  12 */     System.out.println("[ControllerAgent] Initializing controller injection...");
/*  13 */     System.out.println("[ControllerAgent] ========================================");
/*  14 */     paramInstrumentation.addTransformer(new ControllerTransformer(), true);
/*  15 */     System.out.println("[ControllerAgent] Transformer registered");
/*     */   }
/*     */   
/*     */   static class ControllerTransformer implements ClassFileTransformer {
/*  19 */     private final ClassPool pool = ClassPool.getDefault();
/*     */ 
/*     */     
/*     */     public byte[] transform(ClassLoader param1ClassLoader, String param1String, Class<?> param1Class, ProtectionDomain param1ProtectionDomain, byte[] param1ArrayOfbyte) {
/*     */       if (param1String == null || param1String.contains("$$Lambda") || param1String.contains("$Proxy")) {
/*     */         return null;
/*     */       }
/*     */       try {
/*     */         if (param1String.equals("com/badlogic/gdx/controllers/desktop/DesktopControllerManager")) {
/*     */           return transformControllerManager(param1String);
/*     */         }
/*     */         if (param1String.equals("com/megacrit/cardcrawl/helpers/controller/CInputHelper")) {
/*     */           return transformCInputHelper(param1String);
/*     */         }
/*     */         if (param1String.equals("com/megacrit/cardcrawl/helpers/controller/CInputListener")) {
/*     */           return transformCInputListener(param1String);
/*     */         }
/*     */         if (param1String.equals("com/megacrit/cardcrawl/helpers/input/InputHelper")) {
/*     */           return transformInputHelper(param1String);
/*     */         }
/*     */         if (param1String.equals("com/badlogic/gdx/backends/lwjgl/LwjglInput")) {
/*     */           return transformLwjglInput(param1String);
/*     */         }
/*     */         if (param1String.equals("com/megacrit/cardcrawl/core/DisplayConfig")) {
/*     */           return transformDisplayConfig(param1String);
/*     */         }
/*     */         if (param1String.equals("com/megacrit/cardcrawl/desktop/DesktopLauncher")) {
/*     */           return transformDesktopLauncher(param1String);
/*     */         }
/*     */       } catch (Exception exception) {
/*     */         System.err.println("[ControllerAgent] Transform failed for " + param1String);
/*     */         exception.printStackTrace();
/*     */       } 
/*     */       return null;
/*     */     }
/*     */ 
/*     */     
/*     */     private byte[] transformControllerManager(String param1String) throws Exception {
/*  57 */       System.out.println("[ControllerAgent] Transforming: " + param1String);
/*     */       
/*  59 */       CtClass ctClass = this.pool.get(param1String.replace('/', '.'));
/*     */       
/*  61 */       CtConstructor[] arrayOfCtConstructor = ctClass.getConstructors();
/*  62 */       for (CtConstructor ctConstructor : arrayOfCtConstructor) {
/*  63 */         ctConstructor.insertAfter("spire.agent.VirtualControllerInjector.injectController(this.controllers);");
/*     */       }
/*     */ 
/*     */ 
/*     */       
/*  68 */       byte[] arrayOfByte = ctClass.toBytecode();
/*  69 */       ctClass.detach();
/*  70 */       return arrayOfByte;
/*     */     }
/*     */     
/*     */     private byte[] transformCInputHelper(String param1String) throws Exception {
/*  74 */       System.out.println("[ControllerAgent] Transforming: " + param1String);
/*     */       
/*  76 */       CtClass ctClass = this.pool.get(param1String.replace('/', '.'));
/*     */       
/*  78 */       CtMethod ctMethod1 = ctClass.getDeclaredMethod("initializeIfAble");
/*  79 */       ctMethod1.insertAfter("spire.agent.VirtualControllerInjector.ensureListenerRegistered();spire.agent.VirtualControllerInjector.makePrimaryController();spire.agent.KeyboardBlocker.install();");
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */       
/*  86 */       CtMethod ctMethod2 = ctClass.getDeclaredMethod("listenerPress");
/*  87 */       ctMethod2.insertBefore("System.out.println(\"[CInputHelper] listenerPress called with keycode: \" + $1);");
/*     */ 
/*     */       
/*  90 */       ctMethod2.insertAfter("{  System.out.println(\"[CInputHelper] After listenerPress, checking actions:\");  for (int i = 0; i < actions.size(); i++) {    com.megacrit.cardcrawl.helpers.controller.CInputAction action =       (com.megacrit.cardcrawl.helpers.controller.CInputAction)actions.get(i);    if (action.keycode == $1) {      System.out.println(\"[CInputHelper]   Found action with keycode \" + $1 +         \": justPressed=\" + action.justPressed + \", pressed=\" + action.pressed);    }  }}");
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */       
/* 104 */       CtMethod ctMethod3 = ctClass.getDeclaredMethod("updateLast");
/* 105 */       ctMethod3.insertAfter("spire.agent.KeyboardToControllerBridge.updateFromKeyboard();");
/*     */ 
/*     */ 
/*     */       
/* 109 */       System.out.println("[ControllerAgent] Successfully hooked CInputHelper");
/*     */       
/* 111 */       byte[] arrayOfByte = ctClass.toBytecode();
/* 112 */       ctClass.detach();
/* 113 */       return arrayOfByte;
/*     */     }
/*     */     
/*     */     private byte[] transformCInputListener(String param1String) throws Exception {
/* 117 */       System.out.println("[ControllerAgent] Transforming: " + param1String);
/*     */       
/* 119 */       CtClass ctClass = this.pool.get(param1String.replace('/', '.'));
/*     */       
/* 121 */       CtMethod ctMethod1 = ctClass.getDeclaredMethod("buttonDown");
/* 122 */       ctMethod1.setBody("{  System.out.println(\"[CInputListener] buttonDown: buttonCode=\" + $2 + \" calling listenerPress\");  com.megacrit.cardcrawl.core.Settings.CONTROLLER_ENABLED = true;  com.megacrit.cardcrawl.core.Settings.isControllerMode = true;  com.megacrit.cardcrawl.core.Settings.isTouchScreen = false;  boolean result = com.megacrit.cardcrawl.helpers.controller.CInputHelper.listenerPress($2);  System.out.println(\"[CInputListener] listenerPress returned: \" + result);  return false;}");
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */       
/* 134 */       CtMethod ctMethod2 = ctClass.getDeclaredMethod("buttonUp");
/* 135 */       ctMethod2.setBody("{  System.out.println(\"[CInputListener] buttonUp: buttonCode=\" + $2 + \" calling listenerRelease\");  boolean result = com.megacrit.cardcrawl.helpers.controller.CInputHelper.listenerRelease($2);  System.out.println(\"[CInputListener] listenerRelease returned: \" + result);  return false;}");
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */       
/* 144 */       CtMethod ctMethod3 = ctClass.getDeclaredMethod("axisMoved");
/* 145 */       ctMethod3.insertBefore("com.megacrit.cardcrawl.core.Settings.CONTROLLER_ENABLED = true;com.megacrit.cardcrawl.core.Settings.isControllerMode = true;");
/*     */ 
/*     */ 
/*     */ 
/*     */       
/* 150 */       CtMethod ctMethod4 = ctClass.getDeclaredMethod("povMoved");
/* 151 */       ctMethod4.insertBefore("com.megacrit.cardcrawl.core.Settings.CONTROLLER_ENABLED = true;com.megacrit.cardcrawl.core.Settings.isControllerMode = true;");
/*     */ 
/*     */ 
/*     */ 
/*     */       
/* 156 */       System.out.println("[ControllerAgent] Successfully replaced CInputListener methods");
/*     */       
/* 158 */       byte[] arrayOfByte = ctClass.toBytecode();
/* 159 */       ctClass.detach();
/* 160 */       return arrayOfByte;
/*     */     }
/*     */     
/*     */     private byte[] transformInputHelper(String param1String) throws Exception {
/* 164 */       System.out.println("[ControllerAgent] Transforming: " + param1String);
/*     */       
/* 166 */       CtClass ctClass = this.pool.get(param1String.replace('/', '.'));
/*     */       
/* 168 */       CtMethod[] arrayOfCtMethod = ctClass.getDeclaredMethods();
/* 169 */       for (CtMethod ctMethod : arrayOfCtMethod) {
/* 170 */         if (ctMethod.getName().equals("updateFirst")) {
/* 171 */           ctMethod.insertBefore("{  if (com.megacrit.cardcrawl.core.Settings.isControllerMode == false) {    com.megacrit.cardcrawl.core.Settings.isControllerMode = true;  }  if (com.megacrit.cardcrawl.core.Settings.CONTROLLER_ENABLED == false) {    com.megacrit.cardcrawl.core.Settings.CONTROLLER_ENABLED = true;  }}");
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */           
/* 181 */           System.out.println("[ControllerAgent] Hooked InputHelper.updateFirst");
/*     */           
/*     */           break;
/*     */         } 
/*     */       } 
/* 186 */       byte[] arrayOfByte = ctClass.toBytecode();
/* 187 */       ctClass.detach();
/* 188 */       return arrayOfByte;
/*     */     }
/*     */     
/*     */     private byte[] transformLwjglInput(String param1String) throws Exception {
/* 192 */       System.out.println("[ControllerAgent] Transforming: " + param1String);
/*     */       
/* 194 */       CtClass ctClass = this.pool.get(param1String.replace('/', '.'));
/*     */ 
/*     */       
/* 197 */       CtMethod ctMethod = ctClass.getDeclaredMethod("isKeyPressed");
/* 198 */       ctMethod.setBody("return false;");
/*     */ 
/*     */       
/*     */       try {
/* 202 */         CtMethod ctMethod1 = ctClass.getDeclaredMethod("isKeyJustPressed");
/* 203 */         ctMethod1.setBody("return false;");
/* 204 */       } catch (Exception exception) {}
/*     */ 
/*     */ 
/*     */       
/* 208 */       System.out.println("[ControllerAgent] Blocked LwjglInput keyboard methods");
/*     */       
/* 210 */       byte[] arrayOfByte = ctClass.toBytecode();
/* 211 */       ctClass.detach();
/* 212 */       return arrayOfByte;
/*     */     }
/*     */     
/*     */     private byte[] transformDisplayConfig(String param1String) throws Exception {
/*     */       String str1 = System.getProperty("sts.width");
/*     */       String str2 = System.getProperty("sts.height");
/*     */       if (str1 == null || str2 == null)
/*     */         return null; 
/*     */       System.out.println("[ControllerAgent] DisplayConfig override: " + str1 + "x" + str2);
/*     */       CtClass ctClass = this.pool.get(param1String.replace('/', '.'));
/*     */       CtMethod ctMethod1 = ctClass.getDeclaredMethod("getWidth");
/*     */       ctMethod1.setBody("{ return Integer.parseInt(System.getProperty(\"sts.width\")); }");
/*     */       CtMethod ctMethod2 = ctClass.getDeclaredMethod("getHeight");
/*     */       ctMethod2.setBody("{ return Integer.parseInt(System.getProperty(\"sts.height\")); }");
/*     */       byte[] arrayOfByte = ctClass.toBytecode();
/*     */       ctClass.detach();
/*     */       return arrayOfByte;
/*     */     }
/*     */     
/*     */     private byte[] transformDesktopLauncher(String param1String) throws Exception {
/*     */       String str1 = System.getProperty("sts.width");
/*     */       String str2 = System.getProperty("sts.height");
/*     */       if (str1 == null || str2 == null)
/*     */         return null; 
/*     */       System.out.println("[ControllerAgent] DesktopLauncher override: " + str1 + "x" + str2);
/*     */       CtClass ctClass = this.pool.get(param1String.replace('/', '.'));
/*     */       CtMethod ctMethod = ctClass.getDeclaredMethod("loadSettings");
/*     */       ctMethod.insertAfter("{ int _w = Integer.parseInt(System.getProperty(\"sts.width\"));  int _h = Integer.parseInt(System.getProperty(\"sts.height\"));  $1.width = _w; $1.height = _h; $1.fullscreen = false;  System.out.println(\"[ControllerAgent] LWJGL config forced to \" + _w + \"x\" + _h); }");
/*     */       byte[] arrayOfByte = ctClass.toBytecode();
/*     */       ctClass.detach();
/*     */       return arrayOfByte;
/*     */     }
/*     */   }
/*     */ }


/* Location:              /home/dia/Desktop/slaythespire/slaythespire/controller-injector.jar!/spire/agent/ControllerInjectionAgent.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       1.1.3
 */