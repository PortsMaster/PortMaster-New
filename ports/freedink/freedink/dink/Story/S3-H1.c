void main( void )
{
 preload_seq(391);
 preload_seq(393);
 preload_seq(397);
 preload_seq(399);
 int &guy;
 //Create the freak guy....
 &guy = create_sprite(333, 129, 0, 0, 0);
 sp_brain(&guy, 16);
 sp_base_walk(&guy, 390);
 sp_speed(&guy, 4);
 sp_timing(&guy, 0);
 //set starting pic
 sp_pseq(&guy, 391);
 sp_pframe(&guy, 1);
 sp_script(&guy, "s3-freak");
}
 