void main( void )
{
sp_hitpoints(&current_sprite, 5);

}
//this is a special kill script just ducks, so you can run something
//when their headless body is killed also (die is run as soon as they are
//killed, which is too early for what we want to do)

void duckdie( void )
{

&save_x = sp_x(&current_sprite, -1);
&save_y = sp_y(&current_sprite, -1);
external("make","foodduck");

if (get_sprite_with_this_brain(3, &current_sprite) == 0)
 {
  //no more brain 3 ducks here, lets rock
spawn("s4-end");

 }
}
