void main( void )
{
 preload_seq(361);
 preload_seq(363);
 preload_seq(367);
 preload_seq(369);
 //Spawn guy
 int &pep;
 &pep = create_sprite(348, 149, 0, 0, 0);
 sp_brain(&pep, 16);
 sp_base_walk(&pep, 360);
 sp_speed(&pep, 1);
 sp_timing(&pep, 0);
 //set starting pic
 sp_pseq(&pep, 363);
 sp_pframe(&pep, 1);
 sp_script(&pep, "s6-st1p"); 
}

