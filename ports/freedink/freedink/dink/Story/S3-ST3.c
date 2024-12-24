void main( void )
{
 preload_seq(417);
 preload_seq(419);
 preload_seq(413);
 preload_seq(411);
 preload_seq(331);
 preload_seq(333);
 preload_seq(337);
 preload_seq(339);
 //Spawn guy
 int &pep;
 &pep = create_sprite(300, 200, 0, 0, 0);
 sp_brain(&pep, 16);
 sp_base_walk(&pep, 410);
 sp_speed(&pep, 1);
 sp_timing(&pep, 0);
 //set starting pic
 sp_pseq(&pep, 413);
 sp_pframe(&pep, 1);
 sp_script(&pep, "s3-larry");
}
