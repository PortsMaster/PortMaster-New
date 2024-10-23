#!/usr/bin/env python3
import sys
import argparse

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

    parser = argparse.ArgumentParser(description='K-dog Gamepad button swapper tool: swap one or more pair of button in the SDL GAMECONTROLLER CONFIG')
    parser.add_argument('-i', '--input', default="-",help='SDL GAMECONTROLLER CONFIG input file (by default stdin)')
    parser.add_argument('-o', '--output', default="-",help='SDL GAMECONTROLLER CONFIG output file (by default stdout)')
    parser.add_argument('swaplist', action="extend", nargs="+", type=str, help='list of pair of button to swap (eg. a b x y)')

    args = parser.parse_args()

    swaplist = []
    # Setup a list of swap pairs
    for i in range( len(args.swaplist) // 2 ):
        swaplist.append(args.swaplist[ 2 * i : 2 * i + 2 ])
    
    if args.input != '-':
        with open(args.input, 'r') as inputfile:
            lines = inputfile.readlines()
    else:
        lines = sys.stdin

    if args.output != '-':
        output = open(args.output, 'w')
    else:
        output = sys.stdout

    for line in lines:
        # For each line we try to split the parameter with ',' as field delimiter

        splitted_line = line.rstrip().split(',')

        # For each pair of swap we try to find the two parameters and swap them in splitted_line
        for _,swap in enumerate(swaplist):
            # name for a,b fields
            a_name = swap[0]
            b_name = swap[1]

            # column index of the a,b fields
            (a_idx, b_idx) = (-1, -1)

            # a,b gamepad configuration value (eg. "b1", "b2"...)
            (a_val, b_val) = ("", "")

            # Look for a and b parameters in each field
            for i,param in enumerate(splitted_line):

                # For each field split the parameter name (eg. "a") from its value (eg. "b1")
                # delimiter is ":"
                splitted_param = param.split(":")

                if splitted_param[0] == a_name:
                    # we have found parameter for a
                    a_val = splitted_param[1]
                    a_idx = i
                elif splitted_param[0] == b_name:
                    # we have found parameter for b
                    b_val = splitted_param[1]
                    b_idx = i

            if a_idx > -1 and b_idx > -1:
                # We have found a and b so we can swap them
                splitted_line[a_idx] = f"{a_name}:{b_val}"
                splitted_line[b_idx] = f"{b_name}:{a_val}"
        
        # Print the reconstitued line (even we haven't updated it)
        output.write(','.join(splitted_line))
        output.write('\n')

if __name__ == '__main__':
    main()