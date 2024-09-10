void main( void )
{
int &randy;
}

void hit( void )
{
&randy = random(3, 1); 

 if (&randy == 1)
 say("`4Kill him, Girls!", &current_sprite);
 if (&randy == 2)
 say("`4Judgement day has cometh, sinner!", &current_sprite);
 if (&randy == 3)
 say("`4The girls are hungry - DINNER TIME!", &current_sprite);

}

void talk( void )
{
&randy = random(3, 1); 

 if (&randy == 1)
 say("`4You made a mistake coming here.", &current_sprite);
 if (&randy == 2)
 say("`4Your blood will flow like the river Jordan.", &current_sprite);
 if (&randy == 3)
 say("`4Can I interest you in our love gift for December?  Only $80!", &current_sprite);

}

