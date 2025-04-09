void main( void )
{
}

void talk( void )
{
 if (&safe == 0)
 {
 say("`3Help me please!", &current_sprite);
 return;
 }
 else
 {
 playmidi("love.mid");
 freeze(1);
 freeze(&current_sprite);
 say_stop("You okay there pal?", 1);
 wait(200);
 say_stop("`3Thanks to you I am.  Those guys would've killed me!", &current_sprite);
 wait(200);
 say_stop("Yea, I've never seen anything like that happen", 1);
 say_stop("around here before.", 1);
 wait(200);
 say_stop("`3Well, like I said I travel light and don't have", &current_sprite);
 say_stop("`3much with me.", &current_sprite);
 wait(200);
 say_stop("`3Here, take this gold piece, it's all I can spare.", &current_sprite);
 &gold += 1;
 &exp += 15;
 sp_speed(&current_sprite, 3);
 sp_timing(&current_sprite, 0);
 move_stop(&current_sprite, 6, 680, 1);
 unfreeze(&current_sprite);
 unfreeze(1);
 sp_active(&current_sprite, 0);
 }
}
