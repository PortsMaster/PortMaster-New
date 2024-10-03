void main( void )
{
 if (&thief == 2)
 {
 int &poop;
 &vision = 1;
 //so the real warping door will appear
 &poop = create_sprite(300, 200, 0, 0, 0);
 sp_script(&poop, "s2-ryan2");
 }
 if (&thief == 3)
 {
 freeze(1);
 int &bad;
 int &poop;
 int &poop2;
 &bad = create_sprite(370, 190, 0, 0, 0);
 sp_brain(&bad, 0);
 sp_base_walk(&bad, 370);
 sp_speed(&bad, 2);
 sp_timing(&bad, 0);
//set starting pic
 sp_pseq(&bad, 371);
 sp_pframe(&bad, 1);

 &poop = create_sprite(410, 250, 0, 0, 0);
 sp_brain(&poop, 0);
 sp_base_walk(&poop, 290);
 sp_speed(&poop, 2);
 sp_timing(&poop, 0);
//set starting pic
 sp_pseq(&poop, 297);
 sp_pframe(&poop, 1);

 &poop2 = create_sprite(300, 175, 0, 0, 0);
 sp_brain(&poop2, 0);
 sp_base_walk(&poop2, 290);
 sp_speed(&poop2, 2);
 sp_timing(&poop2, 0);
//set starting pic
 sp_pseq(&poop2, 293);
 sp_pframe(&poop2, 1);

 wait(500);
 say_stop("`3Thanks for helping us catch this guy, Dink.", &poop);
 wait(250);
 say_stop("`4Yeah, he's been hounding us for a long time.", &poop2);
 wait(250);
 say_stop("Oh, uh .. glad to be of assistance guys.", 1);
 wait(250);
 say_stop("`4He won't be bothering anyone for quite a while.", &poop2);
 wait(250);
 say_stop("`3Yeah, say, are Tom and Bob ok inside?", &poop);
 wait(250);
 say_stop("Uh.. Yes, they're fine.", 1);
 &tombob = 1;
 wait(250);
 say_stop("`3I guess they'll be right out.", &poop);
 wait(250);
 say_stop("`4Come on, let's get this loser to the jail.", &poop2);
 move(&bad, 8, 130, 1);
 move(&poop, 8, 190, 1);
 move_stop(&poop2, 8, 115, 1);
 move(&bad, 4, -20, 1);
 move(&poop2, 4, -20, 1);
 move_stop(&poop, 4, -20, 1);
 &thief = 4;
 unfreeze(1);
 sp_active(&bad, 0);
 sp_active(&poop, 0);
 sp_active(&poop2, 0);
 }
}
 