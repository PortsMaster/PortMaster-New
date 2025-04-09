void main( void )
{
 preload_seq(251);
 preload_seq(253);
 preload_seq(257);
 preload_seq(259);
 int &what;
 int &pep;
 &what = random(2, 1);
 if (&what == 1)
 {
  &pep = create_sprite(159, 124, 0, 0, 0);
 }
 if (&what == 2)
 {
  &pep = create_sprite(368, 171, 0, 0, 0);
 }
 sp_brain(&pep, 16);
 sp_base_walk(&pep, 250);
 sp_speed(&pep, 1);
 sp_timing(&pep, 0);
 //set starting pic
 sp_pseq(&pep, 251);
 sp_pframe(&pep, 1);
 sp_script(&pep, "s4-st1p");
}
