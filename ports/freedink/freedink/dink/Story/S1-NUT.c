void main( void )
{
sp_touch_damage(&current_sprite, -1);

}

void touch( void )
{
int &junk = free_items();

if (&junk < 1)
 {
 say("I'm full!  I can't pick up anything else.", 1);
 return;
 }
Playsound(10,22050,0,0,0);
add_item("item-nut",438, 19);

        if (&nuttree < 1)
        {
        &nuttree = 1;
        &story = 3;
        }

        say("I picked up a nut!",1);
        sp_active(&current_sprite, 0);

 }
