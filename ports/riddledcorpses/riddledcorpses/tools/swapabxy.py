#!/usr/bin/env python3
import sys

"""
    name: swapabxy tool
    description: swap a/b and x/y button in SDL_GAMECONTROLLERCONFIG
    author: kotzebuedog
    usage:
        export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | ./swapabxy.py`"

    For example:

        # nintendo layout
        19009b4d4b4800000111000000010000,retrogame_joypad,a:b1,b:b0,dpdown:b14,dpleft:b15,+lefty:+a1,-leftx:-a0,+leftx:+a0,-lefty:-a1,leftshoulder:b4,leftstick:b11,lefttrigger:b6,dpright:b16,+righty:+a3,-rightx:-a2,+rightx:+a2,-righty:-a3,rightshoulder:b5,rightstick:b12,righttrigger:b7,back:b8,start:b9,dpup:b13,x:b2,y:b3,platform:Linux,

        becomes

        # nintendo layout
        19009b4d4b4800000111000000010000,retrogame_joypad,a:b0,b:b1,dpdown:b14,dpleft:b15,+lefty:+a1,-leftx:-a0,+leftx:+a0,-lefty:-a1,leftshoulder:b4,leftstick:b11,lefttrigger:b6,dpright:b16,+righty:+a3,-rightx:-a2,+rightx:+a2,-righty:-a3,rightshoulder:b5,rightstick:b12,righttrigger:b7,back:b8,start:b9,dpup:b13,x:b3,y:b2,platform:Linux,


"""

def main():
    for line in sys.stdin:
        # For each line we try to split the parameter with ',' as field delimiter

        splitted_line = line.rstrip().split(',')

        # column index of the a,b,x and y fields
        (a_i, b_i, x_i, y_i) = (-1, -1, -1, -1)

        # a,b,x and y gamepad configuration value (eg. "b1", "b2"...)
        (a, b, x, y) = ("", "", "", "")

        # Look for a,b,x and y parameters in each field
        for i,param in enumerate(splitted_line):

            # For each field split the parameter name (eg. "a") from its value (eg. "b1")
            # delimiter is ":"
            splitted_param = param.split(":")

            if splitted_param[0] == "a":
                # we have found parameter for a
                a = splitted_param[1]
                a_i = i
            elif splitted_param[0] == "b":
                # we have found parameter for b
                b = splitted_param[1]
                b_i = i
            elif splitted_param[0] == "x":
                # we have found parameter for x
                x = splitted_param[1]
                x_i = i
            elif splitted_param[0] == "y":
                # we have found parameter for y
                y = splitted_param[1]
                y_i = i

        if a_i > -1 and b_i > -1:
            # We have found a and b so we can swap them
            splitted_line[a_i] = f"a:{b}"
            splitted_line[b_i] = f"b:{a}"
        if x_i > -1 and y_i > -1:
            # We have found x and y so we can swap them
            splitted_line[x_i] = f"x:{y}"
            splitted_line[y_i] = f"y:{x}"
        
        # Print the reconstitued line (even we haven't updated it)
        print(','.join(splitted_line))

if __name__ == '__main__':
    main()