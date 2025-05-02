# Declare characters used by this game. The color argument colorizes the
# name of the character.

define gui.text_color = "#FFFFFF"
define gui.interface_text_color = "#FFFFFF"

define cf = Character("Sheep Fame", color="#ee7bc5", size=+36)
define any = Character("???")
define crowd = Character("Crowd")
define isa = Character("Isabel", color="#E98B58")
define dan = Character("Dan", color="#2fcc14")
define ory = Character("Oryn", color="#FFFFFF", window_background=Frame("gui/OrynTextbox.png", 25, 25 ) )
define cfxisa = Character("Fame & Isabel", color="#EB867D", size=+30)
define police = Character("Police Assistant", size=+30)
define police2 = Character("Police Officer", size=+30)

# Music

define audio.ravemusic = "<from 21 to 131>MellowRave.mp3"
define audio.ambience = "<from 0 to 101.5>AnxiousAmbience.mp3"
define audio.mystery = "heaven.mp3"

#### N = narrator 

define n = Character("Narrator")
# Anything that uses the character with an n should be remade and dedicated to oryn.



image splashone = "gamejam.png"

image splashtwo = "fictionalfame.png"

image splashthree = "splashhcfspft.png"

label splashscreen:
    
    play sound "audio/incollab.ogg" fadein 1.0 volume 0.8
    # SplashOne
    scene bg black
    with Pause(1)

    show splashone with dissolve
    with Pause(8.5)

    hide splashone with dissolve

    scene bg black with dissolve
    with Pause(1)

    # Splashtwo
    scene bg black
    with Pause(1)

    show splashtwo with dissolve
    with Pause(2)

    hide splashtwo with dissolve
    with Pause(1)

    # Third Splashscreen
    scene bg black
    with Pause(1)

    show splashthree with dissolve
    with Pause(2)

    hide splashthree with dissolve
    with Pause(1)
    

    return



# The game starts here.
label start:
    scene bg black with fade
    # Explain the game. And it's fictonal elements
    
    play music ambience fadein 1.0 volume 1.0 loop

    "{i}Fame rummages around in his closet, before grabbing some clothes and heading to the bathroom to try them on. Talking to himself even-{/i}"
    
    cf "Another Halloween, This time around I'll have to impress people with my new outfit~ I hope they like it.."
    
    play sound "audio/pantson.mp3" fadein 1.0 volume 0.4
    
    scene bg fameshome with fade
    show fame flipannoyed with dissolve
    # "We are greeted with Fame standing there in his Sheep costume. Staring at his own paw as he was curious to how the costume was going as of now."
    
    show fame flipannoyed with dissolve

    cf "Damn uh- This costume.. It's really.."

    cf "Ugh, I already put in some hours into making this.. But-"
    
    cf "This costume is tight as hell.. I'm just glad I don't have to wear it long-, Luckily enough.."
    
    show fame flipnormal with dissolve
    
    cf "Although. It's just a single day, Halloween that is. That's all. I'll be able to put it right back away in the closet!"
    
    show fame flipembarrassed with dissolve

    cf "Well, Do I really have to wear it.. Maybe i could just.."

    # Fame will choose between sleeping or going out to the party.
    
    # Ending1

    menu:
        "Go out":
            jump choices1_progression1
        "Sleep in": 
            jump choices1_ending

label choices1_progression1:
        show fame fliphappy with dissolve

        cf "{i}Shrugs{/i}, Nahhh I'll go just for the free drinks. This shouldn't be a long stay either, Since I already know the queen who is throwing the party~"
        
        "{i}Fame started to leave out! Walking his cute self to the door~ Before finally leaving his house, And locking up each lock.{/i}"
        $ renpy.movie_cutscene("images/CFHBWait.ogv")
        
        scene bg street with fade

        "{i}3 Minutes after..{/i}"
        
        show fame flipnormal at left with moveinleft

        # Fade in street scene

        cf "I should be closer to the house by now. So I'll-"


        "{i}A random person in a zombie costume, Could be seen throwing up on the street ahead~{/i}"

        # Screen shake here
        show fame flipscared with vpunch

        cf "What the fuck had happened!? {i}He said as he watched someone, He may know, Suddenly fall to the ground.{/i}"

        "{i}The guy quickly turned to face Fame!{/i}"

        show unknownman 2any at right with moveinleft

        any "It was because the party! Our drin-! {i}They vomit again in the other direction.{/i}"
        
        # Screen shake.
        
        with vpunch
        any "{b}The drinks at the party were spiked!{/b}"

        hide fame with dissolve
        show fame flipscared at left with vpunch

        cf "How- I know the person throwing it! Why the hell would they spike drinks there?!"
        
        any "{i}Some girl wearing a similar dress came up near them, Puking as well-{/i}"
        
        show unknown 1any at center with moveinleft

        cf "…Fuck it I believe it seeing this.. I'll have to go now, It doesn't make any sense they'd wanna tamper with drinks.."
        
        "{i}They both left in a way that made them look drunk. Just walking off in the distance as Fame saw.{/i}"

        hide unknownman 2any with moveoutleft
        hide unknown 1any with moveoutleft
        
        cf "Well. I'll get back to walking over there. {i}Fame had his tail down all anxious and off put.Then keeps walking forward! Heading straight to the party.{/i}"

        "3 more minutes later."
        
        hide fame
        # Show street to party here
        scene bg black
        "{i}Fame finally approaches a street leading to the house. Thinking to himself before he was gonna get in.{/i}"
        
        cf "Phew, This is the place."

        # show bg streethouse with fade
        
        "{i}Fame would see some people drinking, Turning to look over as he walked in.{/i}"
        
        play music ravemusic fadein 1.5 volume 0.8 loop
        show bg partylivingroomdrink with fade
        
        # The introduction to the party

        any "Wuh Hooooo!"
        
        show fame embarrassed at right
        crowd "{b}Chug Chug Chug Chug!{/b}"

        "{i}The random individual Infront of Fame was drinking loads of root beer. It even seems like he was getting nauseous as more and more went down.{/i}"
        
        show fame normal with dissolve
        cf "Jeez.. Hopefully they'll be fine, I mean. What could happennnn!"

        n "At that point you could already realize what was soon to come."
        
        show fame sad with dissolve
        "{i}The guy soon throws up onto the wall Infront of him. Basically dirtying it all over.{/i}"

        cf "Wh- What the fuck!?"

        "{i}Fame stares over! Seeing as the guy laid there. Looking woozy and unhealthy.{/i}"

        "{i}Suddenly. After a few seconds passed..{/i}"

        "{i}It seemed the host of the costume party came down and stared towards the mess. Annoyed, Confused and worried, But mainly showing off annoyance-{/i}"

        any "{b}What the hell happened down here!!{/b}"

        show isabel flipmad at left with move
        
        # The introduction to the masked girl.

        "{i}The girl came down furious and confused..{/i}" 
        
        "{i}Before peeking over at the sight of the man-{/i}"

        show isabel flipsad with dissolve

        isa "Wait a moment- Huh?? Is that guy passed out?!"

        "{i}The so-called friends surrounding him. Hastily helped him up and left.{/i}"

        crowd "Oh no no no! He's fineeee, {size=-10}We hope!{/size}"

        "{i}The guy for sure was not awake anymore. But the friends left in a rush, Moving to another location!{/i}"

        show bg partylivingroom with fade

        any "Wait! I gotta.. Check his pulse! {size=-10}I can’t be liable for this.. Can i..?{/size}"

        show isabel flipscared with dissolve

        any "{i}The girl seemed to have gotten distracted. Facing away from the accident and thinking.{/i}"
        
        cf "{i}cough cough{/i}, Soooo, Not gonna say hello..?"
        show isabel flipembarrassed with dissolve

        "{i}The sound of the random person surprised the girl!{/i}"

        any "Oh! It's you! You! ████, {i}They were talking about Fame.{/i}"
        show isabel fliphappy with dissolve

        cf "You can still just call me Fame like you started picking up the last time we talked..! But ummm.. I’m glad to!-"
        show fame normal

        scene bg famexisa with fade
        hide fame
        hide isabel
        
        "{i}The girl who Fame knew as: 'Isabel'. Quickly hugs him in excitement to see him at her own party!{/i}"        

        # show fame happy with dissolve
        isa "How have you been Dude!"

        # show image hugartwork with dissolve
        "{i}They both move away from their hug.{/i}"
         
        scene bg partylivingroom with fade
        show fame happy at right
        show isabel happy at left

        cf "Not doing too much really! I stopped by to get a drink.. But uh- something is wrong with your supplies.."
        
        show isabel flipsad with dissolve

        "{i}Her eyes had lowered as she knew what was up with them- And quickly ran to check up on them!{/i}"
        
        hide isabel sad with moveoutleft
        show fame embarrassed at center with moveinleft
        
        
        scene bg partykitchen with fade
        play music ambience fadein 1.0 volume 1.0 loop
        
        isa "So that guy was here. To think I could get away from him.. {i}She was getting ready to go out back and dump out drinks. But Fame was able to get in one more question.{/i}"
        show fame flipsad at left with moveinleft
        show isabel embarrassed at right with fade

        isa "The note I received had the name 'Dan' at the bottom! {i}She left quickly. Probably carrying the drinks to the back of the house difficulty.{/i}"
        
        hide isabel with moveoutright
        
        cf "{i}Fame awkwardly stood there confused.{/i}- Who's Dan..? I never met someone with that name.."

        cf "{i}She would of already left in a hurry.{/i} Hmph... Damn it.."

        n "{i}But during this.. Fame had the unexpected emergency to use the bathroom. Making him leave the kitchen in eagerly!{/i}"

        cf  "Hellll, I'm gonna piss if I don't deal with this.. {i}Fame moved up to the steps. walking up them still very eagerly!{/i}"
        
        n "{i}At this point. Fame has reached the point of trouble, Making this an interesting read.{/i}"

        show fame embarrassed at center with moveinleft
        hide fame with moveoutleft

        scene bg bathroomoutside with fade

        cf "This should be the bathroom!, Just don't know if somebody's in there.."
        
        play sound "doorknock.mp3"

        cf "Phew, A piss break is always a good kind of break. Lucky I get one myself~ {i}Fame was at the toilet. Utilizing it for his own reason, Standing there still feeling that unusual presence… But continuing to shrug it off.{/i}"
    # Keep Going
        cf "I'll just go in and stop wasting my time."

        n "Something he'll soon come to regret saying."
        
        scene bg partybathroom with fade
        
    # ———Dan! The man to catch————

        cf "Phew, A piss break is always a good kind of break. Lucky I get one myself~ {i}Fame was at the toilet. Utilizing it for his own reason, Standing there still feeling that unusual presence… But continuing to shrug it off.{/i}"
        show fame embarrassed at center with moveinleft

        "{i}Fame finally finished up in the bathroom, Just starting to wash his hands. Then common routine of checking his breath! Thinking he needed to improve it. Urging the boy to get a mint out of the small bowl!{/i}"


        # -If he uses a mint, activate the second ending (Minty Death~)-

        menu:
            "Let's grab a mint!":
                jump choices2_mintdeath
            "Meh, I should help out.":
                jump choices2_nomint

label choices2_mintdeath:
    # death
    $ renpy.checkpoint()
    cf "That girl seemed to of outdone herself, Free mint’s for people.."

    cf "May as well take the mint."

    "{i}Fame grabbed a mint from a small bowl, starting to unwrap it. Which silenced the noise of rummaging in the back of the room- An sound similar to that of a window...{/i}"

    "{i}The magenta-haired boy easily got distracted enjoying the mint, Calming his eyes, And relaxing as he had something to enjoy. But the only problem was something joined the room with him. Quickly making him notice the figure in the mirror before he was too late. He even choked on the mint, Feeling something more chemical flavored then minty flavored.{/i}"
     
    show fame scared with vpunch
    
    "{i}The mysterious barely visible figure appears from behind the back of the bathroom, Sprinting quickly at Fame!{/i}"

    show dan knife at right

    hide fame with vpunch

    cf "Huh! What the- {i}The protagonist now fell to their arms. Before something sharp quickly and eagerly stabbed at their vital organs.{/i}"
    
    scene bg famesdeath with fade 

    dan "Shhhhhh~"

    dan "Relaxxx~ {i}They cover Fame’s mouth, Waiting until he stopped breathing or moving before dragging him out the window.{/i}"
    
    play sound "audio/stairwalk.mp3" fadein 1.0 volume 0.4

    # Play an oryn ending here. Or else this below.

    n "At this point Fame seemed to be dead. This wasn’t good at all.. But. This isn’t their only ending. How about, We try something else."
    
    # death ending oryn

    scene bg orynclosed with fade

    play music mystery fadein 1.2 volume 0.8 loop

    ory "Even still, What a sad end to our little… story."

    ory "A Wondrous Tale of Fortune and Tragedy"
    
    ory "7 souls all in one place, Destined to rot and disintegrate with time, With a certain boy, intertwined with their slurry of meaningless thoughts."
    
    ory "For I, the golden king in disguise, has come to save them for their everlasting torment and to forgive them of their Sins."

    ory "But never mind that, you aren’t here to hear about me."
    scene bg orynopen with fade

    ory "You’re looking for an ending to this story, right?"
    ory "Well, you got it."

    ory "Are you satisfied?"

    return

label choices2_nomint:
    # no death
    
    cf "It’s probably faster to take care of it at home. But dam- Would a mint of been nice.."

    "As he was leaving the bathroom! A semi-visible figure rushes at them! Making him quickly leave and hold the door shut on the other end of the bathroom."
    hide fame with moveoutleft
    
    # Dan black with vpunch show

    cf "{i}Fame knew something was up with the bathroom! And having something noticeable like that rush inside the room made him realize he was right!{/i}!"
    
    
    # Dan black hide fade

    cf "{i}Fame would yell out the girl’s name!{/i}: Isabel! I think someone’s hiding up here!"

    
    # Cut to a quick downstairs scene of her running from the right to the left
    
    scene bg partylivingroom with fade
    show isabel sad at left with moveinright
    hide isabel at left with moveoutleft
    play sound "audio/stairwalk.mp3" fadein 1.0 volume 0.4

    scene bg partybathroom with fade
    
    isa "{i}She starts yelling back at Fame-{/i} Is it him!?"
    
    isa "{i}The same girl rushed to the staircase. Replying back to the magenta-haired boy-{/i} Is it him!?"
    
    "{i}Fame still kept the bathroom door held down, With the person on the other side not leaving this time. But once the girl got upstairs! Our protagonist opened the door to quickly charge and tackle the figure!/i}"
    
    scene bg isabhold with fade
    
    cf "Gotcha! Isabel! Help me hold him down-"

    "Fame waited before she quickly helped!"

    isa "I’ll keep him pinned! Why do you want me to-?"

    scene bg famestep with fade

    "{i}Fame quickly kick’s multiple times at the killer’s body body.{/i}"

    play sound "audio/kicksound.mp3" fadein 1.0 volume 0.4

    cf "Don't underestimate my senses! Or the next time you'll be strangled by these hands."
    
    cf "You deserve all this and more for disrupting my friend's party! She spent a whole day setting up for this you bastard!"

    n "{i}Fame was clearly angry about what happened. Getting their frustration out by kicking this guy who showed they didn't care about what they did.{/i}"

    cf "MotherFuckaaaaaa!"

    isa "{i}Couldn’t help but chuckle silently at Fame’s sounds of anger{/i}"

    "{i}After a small period of time. One of his random barrage of kicks would clearly knock him out. Making that random guy with bad intentions pass out. But not dead as we can tell. Making Fame cry out in anger as he stepped back.{/i}"

    stop sound
    stop music fadeout 1.0

    isa "Woah- You alright there bud? I mean.. He’s probably gonna have a concussion from all that fucking kicking! {i}She visibly face palmed. But she was happy the guy would no longer stalk her after tonight.{/i}"

    # Fade out and show the front of the house again.
    "{i}A few minutes later..{/i}"
    
    $ renpy.movie_cutscene("images/CFHBWait.ogv")
    # —————Police Chat——————
    
    scene bg outsidepartyhouse with fade
    hide fame
    hide isabel

    show fame embarrassed at left with fade
    show isabel annoyed at right with fade

    # Show the front of the house or the inside of the house

    n "{i}After our two intertwined characters captured the killer.{/i}"

    cfxisa "{i}Talking to the police.{/i}"

    n "{i}Fame wait’s next to their girlfriend. Describing and helping with the case.{/i}"

    cf "Any assurance that he'll be placed in prison for good this time..? I'm trying to make sure this case won't be dropped."

    n "Both the older police men ignored the request. But were happy to arrest the man."

    police "You should be glad {b}You{/b} aren't the two being put behind bars for this."

    police2 "This guy has blood stained all over his clothing, He's clearly showing he has no remorse. So we're able to take him into questioning, And affiliate these charges with him alone."
    
    isa "And we appreciate it! Isn't that right."

    cf "{i}Wasn't vocal to the agreement, But acknowledged it by nodding his head along.{/i}"
    

    # Keep Going
    
    "*An hour later..*"
    $ renpy.movie_cutscene("images/CFHBWait.ogv")

    # Fade back to the inside of the house.

    show fame sad at right with moveinright
    show isabel flipsad at left with moveinleft

    "{i}Fame shuts the door and turns to face his friend-{/i}"
    
    show isabel sad at left with dissolve

    play sound "audio/dooropen.mp3" fadein 1.0 volume 0.4

    cf "Sooooo.. All that happened..?"

    cf "Gonna tell me more about this person..?"
    show isabel flipsad at left

    isa  "████, To be honest. I reallyyyy just wanna sleep in and close down shop."

    isa "I mean, I don't mind you staying here, But atleast help out. Don't start-"

    show fame happy at right with dissolve

    cf "Need help in the kitchen, Or the bathroom!?!"

    # Show her laughing
    show isabel fliphappy at left with dissolve

    isa "Both. Butttt! If you help me clean, Instead of talking~ Maybeee, Just maybe. I'll let you stay the night."

    cf "Deal! Just tell me what to do, And I'll get to it!"

    hide fame happy with moveoutleft

    isa "{i}She giggled to herself,{/i} Well, If you're staying atleast do the honors of putting your phone on silent~ I can't guarantee this'll be quick work."
    

    isa "Follow me, Oh. And I hope you have sturdy hips~ Because you're gonna be bending over and sweeping." 
    # Show her facing the other direction and moving.
    
    "{i}She turns and follows him into the kitchen.{/i}"

    hide isabel happy with moveoutleft

    scene bg partykitchen with fade

    n "{i}They could both be seen cleaning the rooms, The hallways, And lastly the kitchen."

    # Animate them both moving the kitchen. And hang the screen there.
    hide isabel with moveoutleft
    hide fame with moveoutleft

    scene bg partykitchendark with fade

    ory "My, It seems this book can finally be closed. I'll continue to wonder what was next for them, But it's not my job to look past the importance."

    # Once their models disappear. Dim the screen and start the ending.

    play music mystery fadein 1.2 volume 0.8 loop

    scene bg orynopenwhite with fade

    ory "Hmmmm…"
    ory "What a disappointment though."
    ory "I really thought more people would have died this time around."
    
    scene bg orynopenwide with dissolve

    ory "I was actually looking forward to it this time..."
     
    return

label choices1_ending:

        $ renpy.checkpoint()
        show fame angry with dissolve
        cf "Screw this! I'm just sleeping in for today. It's too hot.."
        
        scene bg black

        "{i}He throws off the costume as he walks back to his room.{/i}"
         
        play sound "audio/pantson.mp3" fadein 1.0 volume 0.4
         
        cf "Well. Hopefully I didn't miss anything good over there."
        
        play sound "audio/yawn.mp3" fadein 1.0 volume 0.4
        # Insert Fade to ending1 card or oryn
        
        play music mystery fadein 1.2 volume 0.8 loop

        scene bg orynopenwhite with fade
        ory "Hmmm…"
        ory "How boring."

        return
