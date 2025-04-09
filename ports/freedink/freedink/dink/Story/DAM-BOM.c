void main(void )
{
int &fsave_x = sp_x(1, -1);
int &fsave_y = sp_y(1, -1);

int &mycrap = create_sprite(&fsave_x, &fsave_y, 0, 420, 1);
sp_script(&mycrap, "dam-bomn");
&fsave_y -= 19;
&fsave_x -= 17;
int &spark = create_sprite(&fsave_x, &fsave_y, 6, 166, 1);
sp_seq(&spark, 166);
sp_que(&spark, -50);
wait(500);

&fsave_y += 1;
&fsave_x += 1;
sp_x(&spark, &fsave_x);
sp_y(&spark, &fsave_y);

sp_pframe(&mycrap, 3);
wait(500);

&fsave_y += 1;
&fsave_x += 1;
sp_x(&spark, &fsave_x);
sp_y(&spark, &fsave_y);


sp_pframe(&mycrap, 1);
wait(500);

&fsave_y += 1;
&fsave_x += 1;
sp_x(&spark, &fsave_x);
sp_y(&spark, &fsave_y);


sp_pframe(&mycrap, 3);
wait(500);

&fsave_y += 1;
&fsave_x += 1;
sp_x(&spark, &fsave_x);
sp_y(&spark, &fsave_y);



sp_pframe(&mycrap, 1);
wait(500);

&fsave_y += 1;
&fsave_x += 1;
sp_x(&spark, &fsave_x);
sp_y(&spark, &fsave_y);



sp_pframe(&mycrap, 2);
wait(100);
sp_pframe(&mycrap, 3);
wait(100);
sp_pframe(&mycrap, 2);

wait(50);

&fsave_y += 1;
&fsave_x += 1;
sp_x(&spark, &fsave_x);
sp_y(&spark, &fsave_y);



sp_pframe(&mycrap, 1);
wait(50);
sp_pframe(&mycrap, 2);
wait(20);
sp_pframe(&mycrap, 3);
wait(20);
sp_pframe(&mycrap, 2);
wait(20);
sp_pframe(&mycrap, 1);
wait(20);
sp_pframe(&mycrap, 2);
wait(20);
sp_pframe(&mycrap, 3);
wait(20);
sp_pframe(&mycrap, 2);
wait(20);
sp_pframe(&mycrap, 1);
wait(20);
sp_pframe(&mycrap, 2);
wait(20);
sp_pframe(&mycrap, 3);
wait(20);
sp_pframe(&mycrap, 2);
wait(20);
sp_pframe(&mycrap, 1);
wait(20);
sp_active(&spark, 0);
sp_range(&mycrap, 30);
sp_brain(&mycrap, 17);
playsound(6, 22050, 0,0,0);
sp_seq(&mycrap, 161);
//sp_touch_damage(&mycrap, 10);
sp_strength(&mycrap, 8);
 }

