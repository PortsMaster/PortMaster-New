void main( void )
{
 preload_seq(381);
 preload_seq(383);
 preload_seq(387);
 preload_seq(389);
 //Spawn guy
 int &pep;
 &pep = create_sprite(348, 175, 0, 0, 0);
 sp_brain(&pep, 16);
 sp_base_walk(&pep, 380);
 sp_speed(&pep, 1);
 sp_timing(&pep, 0);
 //set starting pic
 sp_pseq(&pep, 383);
 sp_pframe(&pep, 1);
 sp_script(&pep, "s1-boot"); 
}
 