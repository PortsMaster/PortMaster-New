void main( void )
{
 //This is the rest of the robbery
 int &bad1;
 int &bad2;
 int &guy;
 &bad1 = sp(4);
 &bad2 = sp(3);
 &guy = sp(5);
 int &mcounter;
 sp_strength(&bad1, 3);
 sp_strength(&bad2, 2);
 sp_distance(&bad1, 50);
 sp_distance(&bad2, 50);
 sp_exp(&bad1, 30);
 sp_exp(&bad2, 35);

 freeze(1);
 freeze(&bad1);
 freeze(&bad2);
 freeze(&guy);
 //Ok, now start it!
 wait(1000);
 playmidi("battle.mid");
 say_stop("`3Please, I've no money, I'm just traveling light.", &guy);
 wait(200);
 say_stop("`4We'll be the judge of that, where are you headed?", &bad2);
 wait(200);
 move(&guy, 6, 455, 0);
 say_stop("`3I'm just passing through to Windemere sir.", &guy);
 wait(200);
 say_stop("Those are Royal Guards, what are they doing out here ...", 1);
 wait(200);
 say_stop("`4Hah, you still owe us 5 gold pieces for passing through the land.", &bad1);
 wait(200);
 move(&guy, 4, 400, 0);
 say_stop("`3I don't have that much sir.", &guy);
 wait(200);
 say_stop("I don't remember ever being charged.", 1);
 say("`4Ha ha ha ha", &bad1);
 say_stop("`4Ha ha ha ha", &bad2);
 wait(200);
 say("`3Someone, help!", &guy);
 //They attack him...
 sp_target(&bad1, &guy);
 sp_target(&bad2, &guy);
 unfreeze(1);
 unfreeze(&bad1);
 unfreeze(&bad2);
 unfreeze(&guy); 
}

void die( void )
{
	&robbed = 1;
    &safe = 1;
	freeze(&current_sprite);
	say("`1Ahhhhhhh", &current_sprite);
	wait(400);
	sp_active(&current_sprite, 0);
}

void attack( void )
{
playsound(36, 22050,0,&current_sprite, 0);
&mcounter = random(4000,0);
sp_attack_wait(&current_sprite, &mcounter);
}


