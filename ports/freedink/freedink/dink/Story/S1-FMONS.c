void main( void )
{
 sp_hitpoints(&current_sprite, 30);
 sp_base_walk(&current_sprite, 130);
 sp_exp(&current_sprite, 30);
 
 int &how;
 if (&farmer_quest == 1)
 {
	 say_stop("`9You cannot defeat us Mr. Smallwood, we are too much for you.", &current_sprite);
	 say_stop("`9Try your best but you risk your life doing so...", &current_sprite);
 }
 &how = random(3,1);
 if (&how == 1)
 {
  say_stop("`9RRrrr ar a rar a  arrgghhh.", &current_sprite);
  sp_speed(&current_sprite, 9);
  sp_timing(&current_sprite, 0);
  wait(4000);
  sp_speed(&current_sprite, 1);
  sp_timing(&current_sprite, 0);
 }
}

void talk( void )
{
}

void hit( void )
{
	sp_target(&current_sprite, &enemy_sprite);
	playsound(30, 17050, 4000, &current_sprite, 0);
  &how = random(2,1);
  if (&how == 1)
  {
	  say("`9You cannot win, Smallwood.", &current_sprite);
  }
  if (&how == 2)
  {
	  say("`9You cannot win, Smallwood.", &current_sprite);
  }
  sp_speed(&current_sprite, 9);
  sp_timing(&current_sprite, 0);
  wait(2000);
  sp_speed(&current_sprite, 1);
  sp_timing(&current_sprite, 33);
}

void die( void )
{
	&farmer_quest = 2;
        &exp += 40;
	say("`9Damn you ... damn .. you.", &current_sprite);
}
 