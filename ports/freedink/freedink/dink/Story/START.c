//this is run when dink is loaded, directly after the dink.ini file
//is processed.

void main( void )
{
//playavi("anim\rtlogo.avi");

 debug("Loading sounds..");
 load_sound("QUACK.WAV", 1);
 load_sound("PIG1.WAV", 2);
 load_sound("PIG2.WAV", 3);
 load_sound("PIG3.WAV", 4);
 load_sound("PIG4.WAV", 5);
 load_sound("BURN.WAV", 6);
 load_sound("OPEN.WAV", 7);
 load_sound("SWING.WAV", 8);
 load_sound("PUNCH.WAV", 9);
 load_sound("SWORD2.WAV", 10);
 load_sound("SELECT.WAV", 11);
 load_sound("WSCREAM.WAV", 12);
 load_sound("PICKER.WAV", 13);
 load_sound("GOLD.WAV", 14);
 load_sound("GRUNT1.WAV", 15);
 load_sound("GRUNT2.WAV", 16);
 load_sound("SEL1.WAV", 17);
 load_sound("ESCAPE.WAV", 18);
 load_sound("NONO.WAV", 19);
 load_sound("SEL2.WAV", 20);
 load_sound("SEL3.WAV", 21);
 load_sound("HIGH2.WAV", 22);
 load_sound("FIRE.WAV", 23);
 load_sound("SPELL1.WAV", 24);
 load_sound("CAVEENT.WAV", 25);
 load_sound("SNARL1.WAV", 26);
 load_sound("SNARL2.WAV", 27);
 load_sound("SNARL3.WAV", 28);
 load_sound("HURT1.WAV", 29);
 load_sound("HURT2.WAV", 30);
 load_sound("ATTACK1.WAV", 31);
 load_sound("CAVEENT.WAV", 32);
 load_sound("LEVEL.WAV", 33);
 load_sound("SAVE.WAV", 34);
 load_sound("SPLASH.WAV", 35);
 load_sound("SWORD1.WAV", 36);
 load_sound("BHIT.WAV", 37);
 load_sound("SQUISH.WAV", 38);
 load_sound("STAIRS.WAV", 39);
 load_sound("STEPS.WAV", 40);
 load_sound("ARROW.WAV", 41);
 load_sound("FLYBY.WAV", 42);
 load_sound("SECRET.WAV", 43);
 load_sound("BOW1.WAV", 44);
 load_sound("KNOCK.WAV", 45);
 load_sound("DRAG1.WAV", 46);
 load_sound("DRAG2.WAV", 47);
 load_sound("AXE.WAV", 48);
 load_sound("BIRD1.WAV", 49);


int &crap;
fill_screen(0);
sp_seq(1, 0);
sp_brain(1, 13);
sp_pseq(1,10);
sp_pframe(1,8);
sp_que(1,20000);
sp_noclip(1, 1);




&dinklogo = create_sprite(320,240, 0, 196, 1);


int &version = get_version();
if (&version < 103)
  {
   //can't play with old .exe, not all command are supported
Say_xy("`4Error - Scripts require version V1.03+ of dink.exe.  Upgrade!",0, 390);
wait(1);
wait(5000);
kill_game();
return;
  }


&crap = create_sprite(76, 40, 14, 194, 1);
sp_script(&crap, "start-1");
sp_noclip(&crap, 1);
sp_touch_damage(&crap, -1);
&crap = create_sprite(524, 40, 14, 195, 1);
sp_script(&crap, "start-2");
sp_noclip(&crap, 1);
sp_touch_damage(&crap, -1);

//&crap = create_sprite(104, 440, 14, 192, 1);
//sp_noclip(&crap, 1);
//sp_script(&crap, "start-3");
//sp_touch_damage(&crap, -1);

&crap = create_sprite(560, 440, 14, 193, 1);
sp_noclip(&crap, 1);
sp_script(&crap, "start-4");
sp_touch_damage(&crap, -1); 

playmidi("1003.mid");
kill_this_task();
}
