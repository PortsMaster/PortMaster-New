Game controls and command line options

Player one (yellow player) uses cursor keys (up, down, left and right arrow) to move. Player two (green) uses keys R, F, D and G respectively. Players actually don't move, they just set the direction for their character, and as soon there is free space in that direction, he starts moving. Once you start moving, you cannot stop unless you hit the wall. When you host the network game, the controls are the same, but when you join it, then you're controlling players three and four (red and dark-green) with these same controls.

Other keys are P for pausing the game, and ESC to exit the game. If you press ESC in cooperative game, players will lose one life. In duel games, current game ends, and the player with most points at that moment is a winner. This is especially useful when there are some cookies left on screen, but they are impossible to reach.

The following command line options are available:
-w   starts the game in window (as opposed to fullscreen)
-h   uses hardware surfaces if possible (game runs faster, but there were problems with some graphic cards, so software surfaces are default)
-d   use DGA driver on Linux (much faster, but must run as root).
-?   Show summary of all command-line options.
