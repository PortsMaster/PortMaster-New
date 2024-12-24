void main(void)
{
sp_nodraw(&current_sprite, 1);
sp_touch_damage(&current_sprite, -1);
int &myx;
int &myy;
int &rcrap;
int &mcrap;
int &dcrap;
&temp1hold = 0;
}


 void touch (void)
 {

if (&temp1hold != 0)
 return;
sp_touch_damage(&current_sprite, 0);
playsound(42, 10000, 0, 0, 0);
playsound(15, 22000, 0, 0, 0);
&life -= 5;
&myx = sp_x(1,-1);
&myy = sp_y(1,-1);
&myy -= 60;
&mcrap = create_sprite(&myx, &myy, 6, 169, 1);
sp_seq(&mcrap, 169);

&myy -= 30;
&myx -= 30;
&dcrap = create_sprite(&myx, &myy, 6, 169, 3);
sp_seq(&dcrap, 169);
sp_frame(&dcrap, 3);

&myy += 10;
&myx += 60;
&rcrap = create_sprite(&myx, &myy, 6, 169, 6);
sp_seq(&rcrap, 169);
sp_frame(&rcrap, 6);
  say("Ouch!",1);


if (&life < 1)
 {
 return;
 } else
 {
  move_stop(1, 2, 170, 1);
  
sp_touch_damage(&current_sprite, -1);
  }
sp_kill(&mcrap, 1500);
sp_kill(&dcrap, 1500);
sp_kill(&rcrap, 1500);

wait(1000);
sp_brain_parm(&mcrap, 40);
sp_brain(&mcrap, 12);
sp_brain_parm(&dcrap, 40);
sp_brain(&dcrap, 12);
sp_brain_parm(&rcrap, 40);
sp_brain(&rcrap, 12);



 }
