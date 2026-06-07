/*     */ package spire.agent;
/*     */ 
/*     */ import com.badlogic.gdx.controllers.Controller;
/*     */ import com.badlogic.gdx.controllers.ControllerListener;
/*     */ import com.badlogic.gdx.controllers.PovDirection;
/*     */ import com.badlogic.gdx.math.Vector3;
/*     */ import com.badlogic.gdx.utils.Array;
/*     */ import java.util.concurrent.ConcurrentHashMap;
/*     */ 
/*     */ public class VirtualController
/*     */   implements Controller {
/*  12 */   private final String name = "Virtual Keyboard Controller";
/*  13 */   private final Array<ControllerListener> listeners = new Array();
/*  14 */   private final ConcurrentHashMap<Integer, Boolean> buttonState = new ConcurrentHashMap<>();
/*  15 */   private final ConcurrentHashMap<Integer, Float> axisState = new ConcurrentHashMap<>();
/*  16 */   private PovDirection povState = PovDirection.center;
/*     */   
/*     */   public static final int BUTTON_A = 0;
/*     */   
/*     */   public static final int BUTTON_B = 1;
/*     */   
/*     */   public static final int BUTTON_X = 2;
/*     */   public static final int BUTTON_Y = 3;
/*     */   public static final int BUTTON_START = 7;
/*     */   public static final int BUTTON_BACK = 6;
/*     */   public static final int BUTTON_LB = 4;
/*     */   public static final int BUTTON_RB = 5;
/*     */   public static final int AXIS_LEFT_X = 1;
/*     */   public static final int AXIS_LEFT_Y = 0;
/*     */   public static final int AXIS_RIGHT_X = 3;
/*     */   public static final int AXIS_RIGHT_Y = 2;
/*     */   
/*     */   public boolean getButton(int paramInt) {
/*  34 */     return ((Boolean)this.buttonState.getOrDefault(Integer.valueOf(paramInt), Boolean.valueOf(false))).booleanValue();
/*     */   }
/*     */ 
/*     */   
/*     */   public float getAxis(int paramInt) {
/*  39 */     return ((Float)this.axisState.getOrDefault(Integer.valueOf(paramInt), Float.valueOf(0.0F))).floatValue();
/*     */   }
/*     */ 
/*     */   
/*     */   public PovDirection getPov(int paramInt) {
/*  44 */     return this.povState;
/*     */   }
/*     */ 
/*     */   
/*     */   public boolean getSliderX(int paramInt) {
/*  49 */     return false;
/*     */   }
/*     */ 
/*     */   
/*     */   public boolean getSliderY(int paramInt) {
/*  54 */     return false;
/*     */   }
/*     */ 
/*     */   
/*     */   public Vector3 getAccelerometer(int paramInt) {
/*  59 */     return Vector3.Zero;
/*     */   }
/*     */ 
/*     */   
/*     */   public void setAccelerometerSensitivity(float paramFloat) {}
/*     */ 
/*     */   
/*     */   public String getName() {
/*  67 */     return "Virtual Keyboard Controller";
/*     */   }
/*     */ 
/*     */   
/*     */   public void addListener(ControllerListener paramControllerListener) {
/*  72 */     if (!this.listeners.contains(paramControllerListener, true)) {
/*  73 */       this.listeners.add(paramControllerListener);
/*  74 */       System.out.println("[VirtualController] Listener registered: " + paramControllerListener.getClass().getName());
/*     */     } 
/*     */   }
/*     */ 
/*     */   
/*     */   public void removeListener(ControllerListener paramControllerListener) {
/*  80 */     this.listeners.removeValue(paramControllerListener, true);
/*     */   }
/*     */   
/*     */   public void setButtonPressed(int paramInt, boolean paramBoolean) {
/*  84 */     boolean bool = ((Boolean)this.buttonState.getOrDefault(Integer.valueOf(paramInt), Boolean.valueOf(false))).booleanValue();
/*     */     
/*  86 */     if (paramBoolean != bool) {
/*  87 */       this.buttonState.put(Integer.valueOf(paramInt), Boolean.valueOf(paramBoolean));
/*     */       
/*  89 */       System.out.println("[VirtualController] Button " + paramInt + " " + (paramBoolean ? "DOWN" : "UP") + " - Listeners: " + this.listeners.size);
/*     */ 
/*     */       
/*  92 */       if (this.listeners.size == 0) {
/*  93 */         System.err.println("[VirtualController] WARNING: NO LISTENERS REGISTERED!");
/*     */       }
/*     */       
/*  96 */       for (ControllerListener controllerListener : this.listeners) {
/*     */         try {
/*  98 */           System.out.println("[VirtualController] Notifying listener: " + controllerListener.getClass().getName());
/*  99 */           if (paramBoolean) {
/* 100 */             boolean bool2 = controllerListener.buttonDown(this, paramInt);
/* 101 */             System.out.println("[VirtualController] buttonDown returned: " + bool2); continue;
/*     */           } 
/* 103 */           boolean bool1 = controllerListener.buttonUp(this, paramInt);
/* 104 */           System.out.println("[VirtualController] buttonUp returned: " + bool1);
/*     */         }
/* 106 */         catch (Exception exception) {
/* 107 */           System.err.println("[VirtualController] Error: " + exception.getMessage());
/* 108 */           exception.printStackTrace();
/*     */         } 
/*     */       } 
/*     */     } 
/*     */   }
/*     */   
/*     */   public void setAxisValue(int paramInt, float paramFloat) {
/* 115 */     paramFloat = Math.max(-1.0F, Math.min(1.0F, paramFloat));
/* 116 */     Float float_ = this.axisState.put(Integer.valueOf(paramInt), Float.valueOf(paramFloat));
/*     */     
/* 118 */     if (float_ == null || Math.abs(float_.floatValue() - paramFloat) > 0.01F) {
/* 119 */       for (ControllerListener controllerListener : this.listeners) {
/* 120 */         controllerListener.axisMoved(this, paramInt, paramFloat);
/*     */       }
/*     */     }
/*     */   }
/*     */   
/*     */   public void setPovDirection(PovDirection paramPovDirection) {
/* 126 */     if (paramPovDirection != this.povState) {
/* 127 */       this.povState = paramPovDirection;
/* 128 */       for (ControllerListener controllerListener : this.listeners) {
/* 129 */         controllerListener.povMoved(this, 0, paramPovDirection);
/*     */       }
/*     */     } 
/*     */   }
/*     */   
/*     */   public int getListenerCount() {
/* 135 */     return this.listeners.size;
/*     */   }
/*     */ }


/* Location:              /home/dia/Desktop/slaythespire/slaythespire/controller-injector.jar!/spire/agent/VirtualController.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       1.1.3
 */