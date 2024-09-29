
void main(void)
{
if(&story > 3)
{
 int &who = sp(22);
 int &who2 = sp(23);
 int &who3 = sp(24);
 int &who4 = sp(20);
 int &who5 = sp(21);
 sp_active(&who,0);
 sp_active(&who2,0);
 sp_active(&who3,0);
 sp_active(&who4,0);
 sp_active(&who5,0);
 sp_active(&current_sprite,0);
 draw_hard_map();
}
}

void talk(void)
{
 if (&story >= 3)
 {
 say("It'll catch fire soon.", 1);
 return;
 }
say("I'm not hungry right now..", 1);
}

void hit(void)
{
 if (&story >= 3)
 {
 say("Ahh, I can't save it.", 1);
 return;
 }
say("Why must I attack furniture?", 1);
}

void push( void )
{
wait(500);

 if (&story >= 3)
 {
 say("It's too big too move!", 1);
 return;
 }
say("This table must be bolted to the ground.", 1);


}


 