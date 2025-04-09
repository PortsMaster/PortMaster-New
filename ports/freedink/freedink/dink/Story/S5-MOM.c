void main( void )
{
 //setup mom

 sp_base_walk(&current_sprite, 360);
 sp_speed(&current_sprite, 1);
 sp_brain(&current_sprite, 16);

 preload_seq(361);
 preload_seq(363);
 preload_seq(365);
 preload_seq(367);
 preload_seq(369);

}
