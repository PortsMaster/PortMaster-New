void main( void )
{
if (&wizard_again == 0)
{
preload_seq(561);
preload_seq(563);
preload_seq(567);
preload_seq(569);
preload_seq(167);

int &scrap = create_sprite(78, 319, 0, 563, 1);
sp_base_walk(&scrap, 560);
sp_script(&scrap, "s1-wiz");
&wizard_again = 1;
}
return;
}

