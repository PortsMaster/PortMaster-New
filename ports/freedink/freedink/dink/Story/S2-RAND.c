void main( void )
{
 int &pap;
 &pap = random(5, 1);
 if (&pap == 1)
 {
//Right now just spawn the dang guy
 preload_seq(391);
 preload_seq(393);
 preload_seq(397);
 preload_seq(399);
 //Spawn guy
 int &pep;
 &pep = create_sprite(326, 300, 0, 0, 0);
 sp_brain(&pep, 16);
 sp_base_walk(&pep, 390);
 sp_speed(&pep, 1);
 sp_timing(&pep, 0);
 //set starting pic
 sp_pseq(&pep, 393);
 sp_pframe(&pep, 1);
 sp_script(&pep, "s2-wand");
 }
}
