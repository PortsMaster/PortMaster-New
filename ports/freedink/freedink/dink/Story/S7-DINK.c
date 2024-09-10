void main(void)
{
}
void talk( void )
{
freeze(1);

say_stop("That... sort of looks like me.", 1);
wait(500);
sp_brain_parm(&current_sprite, 10);
sp_brain(&current_sprite, 12);

  //kill this item so it doesn't show up again for this player
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 1); 

unfreeze(1);

//fix, must make it so that talk() can't be run again
kill_this_task();
}
