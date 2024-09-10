void main( void )
{
 //PAP STORY IS CURRENTLY 6 after your mother dies and you read the letter
 //When the guy in the cave dies it is set to 7, so the storyline with the
 //Cast knights has become established.  Perhaps use this also for whatever
 //way Seth decides to get by the rocks preventing entrance to sector 3.
 //Seth will incriment the number to 8 after you do the cult quest.
 //This event (as in right below) puts it at 9.  And at the parade
 //When you finish that quest it turns to 10 and then you can go to
 //Justin's duck village.
 if (&story == 8)
 {
 int &evil;
 int &evil2;
 //Script for entering Sector 3
 freeze(1);
 //Spawn Stuff
 &evil = create_sprite(-30, 130, 0, 0, 0);
 sp_brain(&evil, 0);
 sp_base_walk(&evil, 300);
 sp_speed(&evil, 1);
 sp_timing(&evil, 0);
 //set starting pic
 sp_pseq(&evil, 303);
 sp_pframe(&evil, 1);
 //Now EVIL's friend
 &evil2 = create_sprite(-30, 210, 0, 0, 0);
 sp_brain(&evil2, 0);
 sp_base_walk(&evil2, 300);
 sp_speed(&evil2, 1);
 sp_timing(&evil2, 0);
 //set starting pic
 sp_pseq(&evil2, 303);
 sp_pframe(&evil2, 1);
 move_stop(1, 4, 580, 1);
 playsound(40,22050,0,0,0);
 wait(1000);
 playsound(40,22050,0,0,0);
 wait(650);
 playsound(40,22050,0,0,0);
 wait(500);
 sp_dir(1, 4);
 wait(500);
 sp_dir(1, 6);
 wait(400);
 sp_dir(1, 2);
 say_stop("I hear someone coming!", 1);
 move_stop(1, 4, 468, 1);
 move_stop(1, 2, 269, 1);
 wait(500);
 playmidi("1005.mid");
 //Move em on screen
 move(&evil, 3, 110, 1);
 wait(670);
 move(&evil2, 6, 130, 1);
 wait(1000);
 say_stop("Hey, those are some of the damn Cast knights.", 1);
 move(&evil2, 9, 150, 1);
 move(&evil, 1, 115, 1);
 wait(250);
 move(&evil2, 4, 100, 1);
 say_stop("What the hell are they doing here?", 1);
 wait(750);
 //They say stuff
 say_stop("`7Area looks clear, I'm ready to head back.", &evil2);
 wait(500);
 say_stop("`5I think we'll be able to raid the town during the festival.", &evil);
 wait(250);
 say_stop("`7Good, right on schedule.  Only WE won't be blamed...", &evil2);
 wait(250);
 say_stop("`5Right.  Have you contacted Mog?", &evil);
 wait(250);
 say_stop("`7Yes.  We sent Joon the bowman.  He speaks their language well.", &evil2);
 wait(250);


 //Move them away or something
 move(&evil, 4, -20, 1);
 wait(420);
 move_stop(&evil2, 4, -20, 1);
 sp_active(&evil, 0);
 sp_active(&evil2, 0);
 wait(500);
 move_stop(1, 4, 300, 1);
 wait(500);
 say_stop("Man, raiding a town!?!", 1);
 wait(400);
 say_stop("A group of those guys would slaughter it.", 1);
 sp_dir(1, 2);
 say_stop("They mentioned a festival ...", 1);
 wait(400);
 say_stop("... wonder if it's around here.", 1);
 &story = 9;
 //They have now seen this....
 unfreeze(1);
 }
}
 