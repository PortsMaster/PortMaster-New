//script for cult girl 5 (mary)

void main( void )
{
preload_seq(331);
preload_seq(333);
preload_seq(337);
preload_seq(339);
sp_base_walk(&current_sprite, 330);
sp_speed(&current_sprite, 1);
//sp_timing(&current_sprite, 66);
sp_pseq(&current_sprite, 337);
sp_pframe(&current_sprite, 1);

}
