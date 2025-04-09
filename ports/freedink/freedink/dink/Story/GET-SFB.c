//sack of grain

void main( void )
{
sp_touch_damage(&current_sprite, -1);
}

void talk(void)
{
Say("A lovely scroll.", 1);
}


void touch(void)
{
//dink touched this sprite
Playsound(10,22050,0,0,0);
sp_brain_parm(&current_sprite, 10);
sp_brain(&current_sprite, 12);
sp_touch_damage(&current_sprite, 0);
sp_timing(&current_sprite, 0);
add_magic("item-sfb",437, 2);
say("I now have the hellfire magic!", 1);
  //kill this item so it doesn't show up again for this player
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 1); 

}
