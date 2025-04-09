void main( void )
{
 preload_seq(341);
 preload_seq(343);
 preload_seq(347);
 preload_seq(349);
 int &what;
 int &pep;
 &what = random(2, 1);
 if (&what == 1)
 {
  &pep = create_sprite(234, 168, 0, 0, 0);
 }
 if (&what == 2)
 {
  &pep = create_sprite(401, 215, 0, 0, 0);
 }
 sp_brain(&pep, 16);
 sp_base_walk(&pep, 340);
 sp_speed(&pep, 1);
 sp_timing(&pep, 0);
 //set starting pic
 sp_pseq(&pep, 341);
 sp_pframe(&pep, 1);
 sp_script(&pep, "s4-st3p");
}
