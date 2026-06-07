/*    */ package spire.agent;
/*    */ 
/*    */ import com.badlogic.gdx.controllers.Controller;
/*    */ import com.badlogic.gdx.controllers.ControllerListener;
/*    */ import com.badlogic.gdx.utils.Array;
/*    */ import java.lang.reflect.Field;
/*    */ 
/*    */ public class VirtualControllerInjector {
/*  9 */   private static VirtualController virtualController = null;
/*    */   private static boolean listenerRegistered = false;
/*    */   
/*    */   public static void injectController(Array<Controller> paramArray) {
/* 13 */     if (virtualController == null) {
/* 14 */       virtualController = new VirtualController();
/* 15 */       paramArray.insert(0, virtualController);
/*    */       
/* 17 */       System.out.println("[ControllerAgent] ========================================");
/* 18 */       System.out.println("[ControllerAgent] Virtual controller injected at index 0!");
/* 19 */       System.out.println("[ControllerAgent] Total controllers: " + paramArray.size);
/* 20 */       System.out.println("[ControllerAgent] ========================================");
/*    */     } 
/*    */   }
/*    */   
/*    */   public static void makePrimaryController() {
/* 25 */     if (virtualController != null) {
/*    */       try {
/* 27 */         Class<?> clazz = Class.forName("com.megacrit.cardcrawl.helpers.controller.CInputHelper");
/*    */         
/* 29 */         Field field = clazz.getDeclaredField("controller");
/* 30 */         field.setAccessible(true);
/*    */         
/* 32 */         Object object = field.get(null);
/*    */         
/* 34 */         if (object != virtualController) {
/* 35 */           field.set(null, virtualController);
/* 36 */           System.out.println("[ControllerAgent] Virtual controller is now PRIMARY!");
/*    */         } 
/* 38 */       } catch (Exception exception) {
/* 39 */         System.err.println("[ControllerAgent] Failed to make primary controller:");
/* 40 */         exception.printStackTrace();
/*    */       } 
/*    */     }
/*    */   }
/*    */   
/*    */   public static void ensureListenerRegistered() {
/* 46 */     if (virtualController != null && !listenerRegistered) {
/*    */       try {
/* 48 */         Class<?> clazz = Class.forName("com.megacrit.cardcrawl.helpers.controller.CInputHelper");
/* 49 */         Field field = clazz.getDeclaredField("listener");
/* 50 */         field.setAccessible(true);
/* 51 */         ControllerListener controllerListener = (ControllerListener)field.get(null);
/*    */         
/* 53 */         if (controllerListener != null) {
/* 54 */           virtualController.addListener(controllerListener);
/* 55 */           listenerRegistered = true;
/* 56 */           System.out.println("[ControllerAgent] Game listener registered!");
/*    */         } 
/* 58 */       } catch (Exception exception) {
/* 59 */         System.err.println("[ControllerAgent] Failed to register listener:");
/* 60 */         exception.printStackTrace();
/*    */       } 
/*    */     }
/*    */   }
/*    */   
/*    */   public static VirtualController getVirtualController() {
/* 66 */     return virtualController;
/*    */   }
/*    */ }


/* Location:              /home/dia/Desktop/slaythespire/slaythespire/controller-injector.jar!/spire/agent/VirtualControllerInjector.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       1.1.3
 */