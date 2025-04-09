void main( void )
{
 //setup mom

 sp_base_walk(&current_sprite, 360);
 sp_speed(&current_sprite, 1);
 sp_brain(&current_sprite, 16);
 sp_hitpoints(&current_sprite, 50);

 preload_seq(361);
 preload_seq(363);
 preload_seq(365);
 preload_seq(367);
 preload_seq(369);
 sp_pseq(&temp2hold, 361);
 sp_pframe(&temp2hold, 1);

}


void die( void )
{
 //dink fails
if (&life > 0)
{
 say("Noooo!  The mother has died!  I HAVE FAILED!!!!!!!", 1);
 &life = 0;
}
}

void talk( void )
{
if (&story > 11)
  say("`#My daughter is just about your age.",&current_sprite);
}
