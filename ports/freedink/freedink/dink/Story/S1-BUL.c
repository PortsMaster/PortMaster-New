void main( void )
{
sp_speed(&current_sprite, 2);
sp_timing(&current_sprite, 0);
sp_base_walk(&current_sprite, 400);
preload_seq(401);
preload_seq(403);
preload_seq(407);
preload_seq(409);

if (&pig_story == 0)
{

        freeze(1);
wait(200);
say_stop("Here, piggie piggies.", 1);
wait(200);

    
        move_stop(&current_sprite, 1, 542, 1)
        playmidi("bullythe.mid");

        say_stop("`6Well, lookie what we got here.", &current_sprite);
        wait(200);
        say_stop("What do you want, Milder?", 1);
        wait(200);
        say_stop("`6Nothing.", &current_sprite);       
        wait(200);
        say_stop("`6'cept to watch you work... Is pig farming fun?", &current_sprite);       
        wait(200);
        say_stop("I'm NOT a pig farmer.", 1);       
        wait(200);
        say_stop("`6Are you feeding pigs right now?", &current_sprite);       
        wait(200);
        say_stop("Er..", 1);       
        wait(200);
        say_stop("Um..", 1);       
        wait(200);
        say_stop("`6Bawahahahah!  See you around, squirt.", &current_sprite);       
        move_stop(&current_sprite, 3, 700, 1)
        say_stop("I *HATE* that guy!", 1);       
        unfreeze(1);
       stopmidi();
        &pig_story = 1;
}

}

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
