void main( void )
{
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 say_stop("`3Hello there.", &current_sprite);
 wait(250);
 say_stop("Hi, who are you?", 1);
 wait(250)
 say_stop("`3I'm the mother duck.", &current_sprite);
 wait(250);
 say_stop("Oh, I see.", 1);
 wait(250);
 say_stop("And how are your kids doing?", 1);
 wait(250);
 say_stop("`3They're fine.", &current_sprite);
 wait(250);
 say_stop("Hey, that's great.", 1);
 unfreeze(1);
 unfreeze(&current_sprite);
}
             
void hit( void )
{
 freeze(&current_sprite);
 say_stop("Yeah, this is fun!", 1);
 unfreeze(&current_sprite);
}

void die ( void )
{
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 

}



