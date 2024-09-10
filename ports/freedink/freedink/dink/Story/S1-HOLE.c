void main( void )
{
preload_seq(452);
}


void touch( void )
{
if (&life < 1) return;

freeze(1);
sp_x(1, 274);
sp_y(1, 195);
sp_seq(1, 452);
sp_frame(1, 1);
sp_nocontrol(1, 1); //dink can't move until anim is done!
sp_touch_damage(&current_sprite, 0);
sp_brain(1, 0);
wait(2000);
sp_brain(1, 1);
&player_map = 131;
sp_x(1, 289);
sp_y(1, 377);
load_screen(131);
draw_screen();
}
