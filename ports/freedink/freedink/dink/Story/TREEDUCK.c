void main( void )
{
int &spr;

}

void hit( void)
{
 say("I feel magical!", &current_sprite);

 &spr = create_sprite(200,200,3,21,1);

sp_base_walk(&spr, 20);
sp_speed(&spr, 1);
sp_timing(&spr, 33);
}
