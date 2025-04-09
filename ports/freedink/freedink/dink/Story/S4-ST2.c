void main( void )
{
 preload_seq(371);
 preload_seq(373);
 preload_seq(377);
 preload_seq(379);
 int &what;
 int &pep;
 &what = random(2, 1);
 if (&what == 1)
 {
  &pep = create_sprite(426, 130, 0, 0, 0);
 }
 if (&what == 2)
 {
  &pep = create_sprite(243, 184, 0, 0, 0);
 }
 sp_brain(&pep, 16);
 sp_base_walk(&pep, 370);
 sp_speed(&pep, 1);
 sp_timing(&pep, 0);
 //set starting pic
 sp_pseq(&pep, 373);
 sp_pframe(&pep, 1);
 sp_script(&pep, "s4-st2p"); 
}
