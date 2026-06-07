/*     */ package spire.agent;
/*     */ 
/*     */ import com.badlogic.gdx.Gdx;
/*     */ import com.badlogic.gdx.Input;
/*     */ import com.badlogic.gdx.controllers.PovDirection;
/*     */ import java.util.HashMap;
/*     */ import java.util.Map;
/*     */ 
/*     */ public class KeyboardToControllerBridge
/*     */ {
/*  11 */   private static final Map<Integer, Integer> KEY_TO_BUTTON = new HashMap<>();
/*  12 */   private static final Map<Integer, Boolean> previousKeyState = new HashMap<>();
/*     */   
/*     */   private static boolean leftPressed = false;
/*     */   private static boolean rightPressed = false;
/*     */   private static boolean upPressed = false;
/*     */   private static boolean downPressed = false;
/*  18 */   private static float prevXAxis = 0.0F;
/*  19 */   private static float prevYAxis = 0.0F;
/*     */   
/*     */   private static boolean initialized = false;
/*     */   
/*     */   static {
/*  24 */     KEY_TO_BUTTON.put(Integer.valueOf(62), Integer.valueOf(0));
/*  25 */     KEY_TO_BUTTON.put(Integer.valueOf(131), Integer.valueOf(1));
/*  26 */     KEY_TO_BUTTON.put(Integer.valueOf(52), Integer.valueOf(2));
/*  27 */     KEY_TO_BUTTON.put(Integer.valueOf(66), Integer.valueOf(3));
/*  28 */     KEY_TO_BUTTON.put(Integer.valueOf(45), Integer.valueOf(4));
/*  29 */     KEY_TO_BUTTON.put(Integer.valueOf(33), Integer.valueOf(5));
/*  30 */     KEY_TO_BUTTON.put(Integer.valueOf(41), Integer.valueOf(6));
/*  31 */     KEY_TO_BUTTON.put(Integer.valueOf(61), Integer.valueOf(7));
/*  32 */     KEY_TO_BUTTON.put(Integer.valueOf(54), Integer.valueOf(-1003));
/*  33 */     KEY_TO_BUTTON.put(Integer.valueOf(46), Integer.valueOf(-1004));
/*     */   }
/*     */   
/*     */   public static void updateFromKeyboard() {
/*  35 */     VirtualController virtualController = VirtualControllerInjector.getVirtualController();
/*  36 */     if (virtualController == null || Gdx.input == null) {
/*     */       return;
/*     */     }
/*     */     
/*  40 */     if (!initialized) {
/*  41 */       System.out.println("[ControllerBridge] Keyboard polling initialized");
/*  42 */       initialized = true;
/*     */     } 
/*     */     
/*  45 */     for (Map.Entry<Integer, Integer> entry : KEY_TO_BUTTON.entrySet()) {
/*  46 */       int i = ((Integer)entry.getKey()).intValue();
/*  47 */       int j = ((Integer)entry.getValue()).intValue();
/*     */ 
/*     */       
/*  50 */       boolean bool = KeyboardBlocker.isKeyPressed(i);
/*  51 */       Boolean bool5 = previousKeyState.get(Integer.valueOf(i));
/*     */       
/*  53 */       if (bool5 == null) bool5 = Boolean.valueOf(false);
/*     */       
/*  55 */       if (bool != bool5.booleanValue()) {
/*  56 */         System.out.println("[ControllerBridge] Key " + Input.Keys.toString(i) + " -> Button " + j + (
/*  57 */             bool ? " PRESSED" : " RELEASED"));
/*  58 */         virtualController.setButtonPressed(j, bool);
/*  59 */         previousKeyState.put(Integer.valueOf(i), Boolean.valueOf(bool));
/*     */       } 
/*     */     } 
/*     */ 
/*     */     
/*  64 */     boolean bool1 = (KeyboardBlocker.isKeyPressed(21) || KeyboardBlocker.isKeyPressed(29));
/*  65 */     boolean bool2 = (KeyboardBlocker.isKeyPressed(22) || KeyboardBlocker.isKeyPressed(32));
/*  66 */     boolean bool3 = (KeyboardBlocker.isKeyPressed(19) || KeyboardBlocker.isKeyPressed(51));
/*  67 */     boolean bool4 = (KeyboardBlocker.isKeyPressed(20) || KeyboardBlocker.isKeyPressed(47));
/*     */     
/*  69 */     if (bool1 != leftPressed || bool2 != rightPressed || bool3 != upPressed || bool4 != downPressed) {
/*  70 */       leftPressed = bool1;
/*  71 */       rightPressed = bool2;
/*  72 */       upPressed = bool3;
/*  73 */       downPressed = bool4;
/*     */       
/*  75 */       float f1 = 0.0F;
/*  76 */       float f2 = 0.0F;
/*     */       
/*  78 */       if (bool1) f1--; 
/*  79 */       if (bool2) f1++; 
/*  80 */       if (bool3) f2--; 
/*  81 */       if (bool4) f2++;
/*     */       
/*  83 */       if (f1 != prevXAxis) {
/*  84 */         virtualController.setAxisValue(1, f1);
/*  85 */         prevXAxis = f1;
/*     */       } 
/*  87 */       if (f2 != prevYAxis) {
/*  88 */         virtualController.setAxisValue(0, f2);
/*  89 */         prevYAxis = f2;
/*     */       } 
/*     */       
/*  92 */       PovDirection povDirection = PovDirection.center;
/*  93 */       if (bool3 && bool2) { povDirection = PovDirection.northEast; }
/*  94 */       else if (bool3 && bool1) { povDirection = PovDirection.northWest; }
/*  95 */       else if (bool4 && bool2) { povDirection = PovDirection.southEast; }
/*  96 */       else if (bool4 && bool1) { povDirection = PovDirection.southWest; }
/*  97 */       else if (bool3) { povDirection = PovDirection.north; }
/*  98 */       else if (bool4) { povDirection = PovDirection.south; }
/*  99 */       else if (bool1) { povDirection = PovDirection.west; }
/* 100 */       else if (bool2) { povDirection = PovDirection.east; }
/*     */       
/* 102 */       virtualController.setPovDirection(povDirection);
/*     */     } 
/*     */   }
/*     */ }


/* Location:              /home/dia/Desktop/slaythespire/slaythespire/controller-injector.jar!/spire/agent/KeyboardToControllerBridge.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       1.1.3
 */