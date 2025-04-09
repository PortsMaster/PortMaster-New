void main( void )
{

 preload_seq(251);
 preload_seq(253);
 preload_seq(257);
 preload_seq(259);

 if (&mayor == 1)
 {
  return;
 }

 if (&mayor == 2)
 {
  return;
 }

 if (&mayor == 5)
 {
  playmidi("lovin.mid");

  freeze(1);
  preload_seq(253);
  preload_seq(251);
  preload_seq(257);
  preload_seq(259);
  preload_seq(271);
  preload_seq(273);
  preload_seq(277);
  preload_seq(279);
  preload_seq(281);
  preload_seq(283);
  preload_seq(287);
  preload_seq(289);
  preload_seq(371);
  preload_seq(373);
  preload_seq(377);
  preload_seq(379);
  preload_seq(361);
  preload_seq(363);
  preload_seq(367);
  preload_seq(369);
  preload_seq(411);
  preload_seq(413);
  preload_seq(417);
  preload_seq(419);
  preload_seq(291);
  preload_seq(293);
  preload_seq(297);
  preload_seq(299);
  int &pp1;
  int &pp2;
  int &pp3;
  int &pp4;
  int &pp5;
  int &pp6;
  int &pp7;
  int &pp8;
  int &pp9;
  int &woman;
  int &mp1;
  int &mp2;
  int &mp3;
  int &mp4;
  int &mp5;
  int &mp6;
  int &mp7;
  //Actually Spawn the girl, and her script
  &woman = create_sprite(400, 110, 0, 0, 0);
  sp_brain(&woman, 16);
  sp_base_walk(&woman, 250);
  sp_speed(&woman, 1);
  sp_timing(&woman, 0);
  //set starting pic
  sp_pseq(&woman, 253);
  sp_pframe(&woman, 1);
  //Create more & more & more!!
  &pp1 = create_sprite(125, 115, 0, 0, 0);
  sp_brain(&pp1, 16);
  sp_base_walk(&pp1, 270);
  sp_speed(&pp1, 1);
  sp_timing(&pp1, 0);
sp_script(&pp1, "s3-peeps");
  //set starting pic
  sp_pseq(&pp1, 273);
  sp_pframe(&pp1, 1);
  &pp2 = create_sprite(250, 141, 0, 0, 0);
  sp_brain(&pp2, 16);
sp_script(&pp2, "s3-peeps");

  sp_base_walk(&pp2, 280);
  sp_speed(&pp2, 1);
  sp_timing(&pp2, 0);
  //set starting pic
  sp_pseq(&pp2, 283);
  sp_pframe(&pp2, 1);
  &pp3 = create_sprite(45, 370, 0, 0, 0);
  sp_brain(&pp3, 16);
  sp_base_walk(&pp3, 370);
  sp_speed(&pp3, 1);
sp_script(&pp3, "s3-peeps");

  sp_timing(&pp3, 0);
  //set starting pic
  sp_pseq(&pp3, 379);
  sp_pframe(&pp3, 1);
  &pp4 = create_sprite(410, 380, 0, 0, 0);
  sp_brain(&pp4, 16);
  sp_base_walk(&pp4, 360);
  sp_speed(&pp4, 1);
  sp_timing(&pp4, 0);
  //set starting pic
  sp_pseq(&pp4, 367);
  sp_pframe(&pp4, 1);
sp_script(&pp4, "s3-peeps");

  &pp5 = create_sprite(520, 360, 0, 0, 0);
  sp_brain(&pp5, 16);
  sp_base_walk(&pp5, 410);
  sp_speed(&pp5, 1);
  sp_timing(&pp5, 0);
  //set starting pic
  sp_pseq(&pp5, 417);
  sp_pframe(&pp5, 1);
sp_script(&pp5, "s3-peeps");

  &pp6 = create_sprite(70, 180, 0, 0, 0);
  sp_brain(&pp6, 16);
  sp_base_walk(&pp6, 220);
  sp_speed(&pp6, 1);
  sp_timing(&pp6, 0);
  //set starting pic
  sp_pseq(&pp6, 223);
  sp_pframe(&pp6, 1);
sp_script(&pp6, "s3-peeps");

  &pp7 = create_sprite(320, 400, 0, 0, 0);
  sp_brain(&pp7, 16);
  sp_base_walk(&pp7, 220);
  sp_speed(&pp7, 1);
  sp_timing(&pp7, 0);
  //set starting pic
  sp_pseq(&pp7, 229);
  sp_pframe(&pp7, 1);
sp_script(&pp7, "s3-peeps");

  &pp8 = create_sprite(295, 50, 0, 0, 0);
  sp_brain(&pp8, 16);
  sp_base_walk(&pp8, 370);
  sp_speed(&pp8, 1);
  sp_timing(&pp8, 0);
  //set starting pic
  sp_pseq(&pp8, 373);
  sp_pframe(&pp8, 1);
sp_script(&pp8, "s3-peeps");

  &pp9 = create_sprite(175, 350, 0, 0, 0);
  sp_brain(&pp9, 16);
  sp_base_walk(&pp9, 390);
  sp_speed(&pp9, 1);
  sp_timing(&pp9, 0);
  //set starting pic
  sp_pseq(&pp9, 399);
  sp_pframe(&pp9, 1);
sp_script(&pp9, "s3-peeps");

  //Let's Go movers!!
  &mp1 = create_sprite(640, 200, 0, 0, 0);
  sp_brain(&mp1, 16);
  sp_base_walk(&mp1, 290);
  sp_speed(&mp1, 1);
  sp_timing(&mp1, 0);
  //set starting pic
  sp_pseq(&mp1, 291);
  sp_pframe(&mp1, 1);
  &mp2 = create_sprite(640, 305, 0, 0, 0);
  sp_brain(&mp2, 16);
  sp_base_walk(&mp2, 290);
  sp_speed(&mp2, 1);
  sp_timing(&mp2, 33);
  //set starting pic
  sp_pseq(&mp2, 291);
  sp_pframe(&mp2, 1);
  &mp3 = create_sprite(640, 320, 0, 0, 0);
  sp_brain(&mp3, 16);
  sp_base_walk(&mp3, 380);
  sp_speed(&mp3, 1);
  sp_timing(&mp3, 20);
  //set starting pic
  sp_pseq(&mp3, 381);
  sp_pframe(&mp3, 1);
  &mp4 = create_sprite(700, 340, 0, 0, 0);
  sp_brain(&mp4, 16);
  sp_base_walk(&mp4, 370);
  sp_speed(&mp4, 1);
  sp_timing(&mp4, 0);
  //set starting pic
  sp_pseq(&mp4, 371);
  sp_pframe(&mp4, 1);
  &mp5 = create_sprite(670, 210, 0, 0, 0);
  sp_brain(&mp5, 16);
  sp_base_walk(&mp5, 390);
  sp_speed(&mp5, 1);
  sp_timing(&mp5, 33);
  //set starting pic
  sp_pseq(&mp5, 391);
  sp_pframe(&mp5, 1);
  &mp6 = create_sprite(710, 180, 0, 0, 0);
  sp_brain(&mp6, 16);
  sp_base_walk(&mp6, 410);
  sp_speed(&mp6, 1);
  sp_timing(&mp6, 0);
  //set starting pic
  sp_pseq(&mp6, 411);
  sp_pframe(&mp6, 1);
  &mp7 = create_sprite(640, 175, 0, 0, 0);
  sp_brain(&mp7, 16);
  sp_base_walk(&mp7, 290);
  sp_speed(&mp7, 1);
  sp_timing(&mp7, 16);
  //set starting pic
  sp_pseq(&mp7, 291);
  sp_pframe(&mp7, 1);
  //Let's Go
  freeze(&woman);
  freeze(&pp1);
  freeze(&pp2);
  //wait(1);
  freeze(&pp3);
  freeze(&pp4);
  freeze(&pp5);
  freeze(&pp6);
  freeze(&pp7);
  freeze(&pp8);
  freeze(&pp9);
	
  freeze(&mp1);
  freeze(&mp2);
  freeze(&mp3);
  freeze(&pp4);
  freeze(&mp4);
  freeze(&mp6);
  freeze(&mp7);
  move(&mp1, 4, -1500, 1);
  move(&mp2, 4, -1500, 1);
  move(&mp3, 4, -1500, 1);
  move(&mp4, 4, -1500, 1);
  move(&mp5, 4, -1500, 1);
  move(&mp6, 4, -1500, 1);
  move(&mp7, 4, -1500, 1);
  wait(500);
  say_stop("`9Dink, Dink, over here.", &woman);
  move_stop(1, 2, 105, 1);
  move_stop(1, 6, 450, 1);
  say_stop("`9Isn't it just beautiful?", &woman);
  sp_dir(1, 4);
  wait(250);
  say_stop("Yup, it's a parade allright.", 1);
  wait(250);
  say_stop("A lot of people too, I shudder at what could've happened.", 1);
  wait(250);
  say_stop("`9You really saved the town Dink...", &woman);
  wait(250);
  say_stop("`9I'm really proud of you.", &woman);
  wait(250);
  say_stop("Thanks, but I couldn't have done it without you.", 1);
  wait(250);
  say_stop("`9Well I have to be going, I have to meet with my father.", &woman);
  wait(250);
  say_stop("`9Take care Dink, I hope I'll see you again.", &woman);
  wait(1000);
  unfreeze(&pp1);
  unfreeze(&pp2);
  unfreeze(&pp3);
  unfreeze(&pp4);
  unfreeze(&pp5);
  unfreeze(&pp6);
  unfreeze(&pp7);
  unfreeze(&pp8);
  unfreeze(&pp9);
  sp_dir(1, 2);
  move_stop(&woman, 3, 660, 1);
  say_stop("Oh, you will baby, you will...", 1);
  &story = 10;
  &mayor = 6;
  unfreeze(1);
  return;
 }

 if (&mayor == 6)
 {
  int &loser;
  &loser = create_sprite(350, 210, 0, 0, 0);
  sp_brain(&loser, 16);
  sp_base_walk(&loser, 410);
  sp_speed(&loser, 1);
  sp_timing(&loser, 0);
  sp_pseq(&loser, 413);
  sp_pframe(&loser, 1);
  sp_script(&loser, "s3-loser");
  return;
 }

 if (&mayor == 7)
 {
  return;
 }
  int &poopy;
  int &woman;
  //Actually Spawn the girl, and her script
  &woman = create_sprite(300, 130, 0, 0, 0);
  sp_brain(&woman, 16);
  sp_base_walk(&woman, 250);
  sp_speed(&woman, 1);
  sp_timing(&woman, 0);
  //set starting pic
  sp_pseq(&woman, 253);
  sp_pframe(&woman, 1);
  sp_script(&woman, "s3-chick");
}
