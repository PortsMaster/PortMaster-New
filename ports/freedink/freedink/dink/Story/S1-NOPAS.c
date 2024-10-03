void main( void )
{
 sp_nodraw(&current_sprite, 1);

if (&story < 5)
 sp_touch_damage(&current_sprite, -1);

}

void touch( void )
{
 Say("I'd best not venture so far from town.  Too dangerous!", 1);
 move_stop(1, 2, 200, 1);
}
