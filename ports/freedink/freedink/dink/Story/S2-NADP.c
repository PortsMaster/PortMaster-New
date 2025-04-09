//script for nadine

void main( void )
{
preload_seq(361);
preload_seq(363);
preload_seq(367);
preload_seq(369);
&temp1hold = &current_sprite;
//lets remember the handle to Nadine, may need to control her with another
//script
int &myrand;
sp_base_walk(&current_sprite, 360);
sp_speed(&current_sprite, 1);
//sp_timing(&current_sprite, 66);

//set starting pic

sp_pseq(&current_sprite, 361);
sp_pframe(&current_sprite, 1);
sp_brain(&current_sprite, 16);

}

void talk( void )
{

 freeze(1);
 freeze(&current_sprite);
         choice_start()
(&s2-nad == 0) "Ask Nadine why her house is such a mess"
(&s2-nad == 1) "Offer to find Nadine's girl"
(&s2-nad == 1) "Be rude to Nadine"
(&s2-nad == 2) "Let her know exactly how fruitless your search has been thus far"
(&s2-nad == 3) "Ask Nadine how she and Mary are doing"
         "Leave"
         choice_end()
        if (&result == 5)
        {
        wait(400);
         say_stop("Say, how are you and the little tike doing?", 1);
        wait(400);
        say_stop("`5Great!", &current_sprite);
        wait(400);
        say_stop("I see you have not had time to clean the house...", 1);
        wait(400);
        say_stop("`5Mary just came home!  We can do that stuff later.", &current_sprite);
        }



        if (&result == 4)
        {
        wait(400);
         say_stop("Little Mary is still out there, somewhere.", 1);
        wait(400);
        say_stop("`5She must be so afraid and lonely out there!", &current_sprite);
        wait(400);
        say_stop("Yes.. unless she was kidnapped by really nice people.", 1);
        wait(400);
        say_stop("`5Please leave now.", &current_sprite);
        }

        if (&result == 1)
        {
        wait(400);
         say_stop("Hi Nadine.  I'm new to town.  Why is your house a pig pen?", 1);
        wait(400);
        say_stop("`5Since my little girl was kidnapped, I've sort of let things go.", &current_sprite);
        wait(400);
        say_stop("Kidnapped?!  Why aren't the townspeople forming a search party?", 1);
        wait(400);
        say_stop("`5They don't care.  We are poor.", &current_sprite);
        &s2-nad = 1;
        }

        if (&result == 2)
        {
        wait(400);
         say_stop("Nadine - I care nothing about your personal finance.  I will help you.", 1);
        wait(400);
        say_stop("`5You.. you will?", &current_sprite);
        wait(400);
        say_stop("Of course.  What was the dear thing's name?", 1);
        wait(400);
        say_stop("`5Mary.  Her name was Mary.", &current_sprite);
        wait(400);
        say_stop("Do you have any idea of who may have taken her?", 1);
        wait(400);
        say_stop("`5No.. no I don't.", &current_sprite);
        wait(400);
        say_stop("Well damn.", 1);
        &s2-nad = 2;
        }

        if (&result == 3)
        {
        wait(400);
         say_stop("Nadine - if you had some cash saved, I would find your girl.", 1);
        wait(400);
        say_stop("`5You know I don't have anything!  Look at my pantry!", &current_sprite);
        wait(400);
        say_stop("No thanks.  Also, your arms look pointy and stupid.", 1);
        wait(400);
        say_stop("`5How dare you!", &current_sprite);
        }


   unfreeze(1);
   unfreeze(&current_sprite);
   return;

}

void hit(void)
{
 int &mcrap = random(4, 1);
    Say("How does it feel?!", 1);
}
