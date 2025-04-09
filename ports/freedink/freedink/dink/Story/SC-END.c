void main( void )
{
 if (&snowc == 0)
 {
  preload_seq(571);
  preload_seq(573);
  preload_seq(577);
  preload_seq(579);
  //Spawn guy
  int &pep;
  &pep = create_sprite(144, 169, 0, 0, 0);
  sp_brain(&pep, 16);
  sp_base_walk(&pep, 570);
  sp_speed(&pep, 1);
  sp_timing(&pep, 0);
  //set starting pic
  sp_pseq(&pep, 573);
  sp_pframe(&pep, 1);
  sp_script(&pep, "sc-wiz");
 }
}
