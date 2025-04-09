void main( void )
{
if (&nuttree == 1)
{
int &who = sp(6);
freeze(1);
freeze(&who);
freeze(&current_sprite);
wait(1000);
say_stop("Hey, that's Lyna with Milder Flatstomp!", 1);
wait(500);
say_stop("`6You know I love you baby... so what's the problem?", &current_sprite);
wait(250);
say_stop("`4Milder... I want to get to know you first.", &who);
wait(250);
say_stop("`4I have a mind too, you know.", &who);
wait(250);
say_stop("`6You kinda talk too much, you know that?", &current_sprite);
wait(250);
say_stop("`4You're an ass!", &who);
wait(250);
unfreeze(&who);
move_stop(&who, 2, 334, 1);
move_stop(&who, 4, -10, 1);
sp_active(&who,0);
say_stop("`6Hhhmph,  chicks!", &current_sprite);
unfreeze(&current_sprite);
move_stop(&current_sprite, 4, 84, 1);
move_stop(&current_sprite, 8, -10, 1);
sp_active(&current_sprite,0);
unfreeze(1);
&nuttree = 2;
}
}
