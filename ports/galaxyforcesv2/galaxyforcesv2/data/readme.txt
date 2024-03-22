
Galaxy Forces V2

A 1-8 player 2D network game. Each player is in control of a ship.
The goal is to kill everything that lives to get the best score (dogfight),
or race against the clock and your opponents to get the fastest time (race).

There is also a mode where the players compete to transport cargo (mission),
and where they cooperate (mission_coop).

High-scores are shown at http://galaxyv2.sourceforge.net/
Create user at http://galaxyv2.sourceforge.net/member_register.php

--------------------------------------------------------------------------------
FIRST

TCP port 1999 must be forwarded to your machine by the router/enabled in the
firewall if you intend to host games and play with others.

You can test if the port is working here (start the game first):
http://www.yougetsignal.com/tools/open-ports/

On Mac, copy 'Server' and the external_map directory to 
"~/Library/Application Support/GalaxyV2"

--------------------------------------------------------------------------------
CONNECT TO SERVER

Enter the IP address or host name of a server and click "connect".
All games on that server will be shown.
You can join Green games.
You can't join Red games, they are full or already started.
If no game is shown you have to create a new game.

The address printed in the top left corner is your external IP. You can
share this to let others connect to you.


LOGIN AS MEBER

To use achievements and hiscores you need to create a user at
http://www.galaxy-forces.com/member_register.php.
Then login as that user, or select cancel to just play directly.


JOIN EXISTING GAME

Enter your name and choose a green game from the list.
Click "Join".


CREATE NEW GAME

Enter your name, and the name of the game.
Click "New".


START GAME

The player that created the game should set the level to play and make other
settings before starting the game.
This player is master, and his computer will control the computer enemies.
Others that have joined the game can only chat until the master starts the game.

The master can kick players by selecting a player and press delete.
If the master leaves the game, mastership is transferred to another player.


VIEW REPLAY

When connected but before a game is joined, click "Replay".
Choose a replay in the list.
Click "Play".


--------------------------------------------------------------------------------
THE GAME

Steering
Keyboard      Pad default    Game Effect
Left arrow/A  Left           Steer Left
Right arrow/D Right          Steer Right
Up arrow/W    Button1        Thrust
Down arrow/S  Down           Prepare ship for landing
Return/space  Button2        Fire

TAB                          Type a chat message
Esc                          Exit
M                            Music on/off
N                            Sound FX on/off
I                            Minimap on/off
F                            Show FPS on/off
7                            Quick restart for a single player game

V                            Change player to follow in replay

Rules
Collect as much points as possible.
Or get the fastest time on the racetracks.
Your ship is fragile; it can only be hit by one bullet!
Everyone is free from there own bullets.
You will die if you hit anything that is not black, both parts of the map
and enemies. You are able to land on the grey landing zones if you are
careful and keep the velocity, angle and position of your ship right.
You don't crash with things on the landing zones.

Mission specific
You finish a mission level by transporting all cargo (small packages on
landing zones) to a home base (landing zone with a warehouse). If you die,
any loaded cargo is re-spawned. You have fuel in your tank to use the thrusters
for 60 seconds. If you run out of fuel, you probably die.
You refuel automatically on home bases.
In mission_coop levels you cooperate to transport the cargo, and all players
get the same score (but only the master get to send in a hiscore).


Score
Collision with the wall    -10
Killed by computer enemy   -10
Collision with opponent    0
Shot by opponent           0
You shot opponent          25  (0 in mission mode)
You shot a computer enemy  Depends of enemy type
Cargo delivered            Depends on the weight of the cargo,
                            the ship can carry max 50

Enemy            Hits to kill   Score
White Tower      4              10
Black Tower      Immortal       -
Blue 3-Shooter   5              20
Black 3-Shooter  Immortal       -
Blue Whirlwind   8              20
Green Guardian   4              15
White 5-shooter  4              25


--------------------------------------------------------------------------------
Requirements
XP/vista/7/8/10/Linux/MacOSX
Soundcard
TCP/IP Network

Game music by Omar Soriano.
Coding and graphics by Ronnie Hedlund.
