void main( void )
{
 preload_seq(231);
 preload_seq(233);
 preload_seq(237);
 preload_seq(239);
 int &pep;
 &pep = create_sprite(300, 130, 0, 0, 0);
 sp_brain(&pep, 9);
 sp_base_walk(&pep, 230);
 sp_speed(&pep, 1);
 sp_timing(&pep, 33);
 //set starting pic
 sp_pseq(&pep, 233);
 sp_pframe(&pep, 1);
 sp_script(&pep, "s3-st1p");

 if (&mayor == 2)
 {
  preload_seq(381);
  preload_seq(383);
  preload_seq(387);
  preload_seq(389);
  int &fat;
  &fat = create_sprite(400, 280, 0, 0, 0);
  sp_brain(&fat, 16);
  sp_base_walk(&fat, 380);
  sp_speed(&fat, 1);
  sp_timing(&fat, 0);
  //set starting pic
  sp_pseq(&fat, 383);
  sp_pframe(&fat, 1);
  sp_script(&fat,"s3-mayor");
 }
 if (&mayor == 4)
 {
  int &fat;
  &fat = create_sprite(400, 280, 0, 0, 0);
  sp_brain(&fat, 16);
  sp_base_walk(&fat, 380);
  sp_speed(&fat, 1);
  sp_timing(&fat, 0);
  //set starting pic
  sp_pseq(&fat, 383);
  sp_pframe(&fat, 1);
  sp_script(&fat, "s3-mayor");
 }
}

