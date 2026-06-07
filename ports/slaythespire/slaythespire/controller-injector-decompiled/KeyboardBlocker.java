/*    */ package spire.agent;
/*    */ 
/*    */ import com.badlogic.gdx.Gdx;
/*    */ import com.badlogic.gdx.InputProcessor;
/*    */ 
/*    */ public class KeyboardBlocker
/*    */   implements InputProcessor {
/*  8 */   private InputProcessor originalProcessor = null;
/*  9 */   private static KeyboardBlocker instance = null;
/*    */ 
/*    */   
/* 12 */   private static boolean[] keyStates = new boolean[256];
/*    */   
/*    */   public static void install() {
/* 15 */     if (instance == null && Gdx.input != null) {
/* 16 */       instance = new KeyboardBlocker();
/* 17 */       instance.originalProcessor = Gdx.input.getInputProcessor();
/* 18 */       Gdx.input.setInputProcessor(instance);
/* 19 */       System.out.println("[KeyboardBlocker] Keyboard blocking installed");
/*    */     } 
/*    */   }
/*    */   
/*    */   public static boolean isKeyPressed(int paramInt) {
/* 24 */     if (paramInt < 0 || paramInt >= 256) return false; 
/* 25 */     return keyStates[paramInt];
/*    */   }
/*    */ 
/*    */   
/*    */   public boolean keyDown(int paramInt) {
/* 30 */     if (paramInt >= 0 && paramInt < 256) {
/* 31 */       keyStates[paramInt] = true;
/* 32 */       System.out.println("[KeyboardBlocker] Captured keyDown: " + paramInt);
/*    */     } 
/* 34 */     return true;
/*    */   }
/*    */ 
/*    */   
/*    */   public boolean keyUp(int paramInt) {
/* 39 */     if (paramInt >= 0 && paramInt < 256) {
/* 40 */       keyStates[paramInt] = false;
/*    */     }
/* 42 */     return true;
/*    */   }
/*    */ 
/*    */   
/*    */   public boolean keyTyped(char paramChar) {
/* 47 */     return true;
/*    */   }
/*    */ 
/*    */   
/*    */   public boolean touchDown(int paramInt1, int paramInt2, int paramInt3, int paramInt4) {
/* 52 */     return (this.originalProcessor != null && this.originalProcessor.touchDown(paramInt1, paramInt2, paramInt3, paramInt4));
/*    */   }
/*    */ 
/*    */   
/*    */   public boolean touchUp(int paramInt1, int paramInt2, int paramInt3, int paramInt4) {
/* 57 */     return (this.originalProcessor != null && this.originalProcessor.touchUp(paramInt1, paramInt2, paramInt3, paramInt4));
/*    */   }
/*    */ 
/*    */   
/*    */   public boolean touchDragged(int paramInt1, int paramInt2, int paramInt3) {
/* 62 */     return (this.originalProcessor != null && this.originalProcessor.touchDragged(paramInt1, paramInt2, paramInt3));
/*    */   }
/*    */ 
/*    */   
/*    */   public boolean mouseMoved(int paramInt1, int paramInt2) {
/* 67 */     return (this.originalProcessor != null && this.originalProcessor.mouseMoved(paramInt1, paramInt2));
/*    */   }
/*    */ 
/*    */   
/*    */   public boolean scrolled(int paramInt) {
/* 72 */     return (this.originalProcessor != null && this.originalProcessor.scrolled(paramInt));
/*    */   }
/*    */ }


/* Location:              /home/dia/Desktop/slaythespire/slaythespire/controller-injector.jar!/spire/agent/KeyboardBlocker.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       1.1.3
 */