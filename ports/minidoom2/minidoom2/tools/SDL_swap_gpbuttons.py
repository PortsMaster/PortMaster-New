#!/usr/bin/env python3
import sys
import argparse

"""
    name: swapabxy tool
    description: swap buttons in SDL_GAMECONTROLLERCONFIG
    author: kotzebuedog
    usage:
        export SDL_GAMECONTROLLERCONFIG="`echo "$SDL_GAMECONTROLLERCONFIG" | ./SDL_swap_gpbuttons.py -i - -o - -l swaplist.txt`"

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
    parser.add_argument('-l', '--list-file',default="SDL_swap_gpbuttons.txt",help='Swap list file. 2-tuples of buttons to swap (eg. "a b" to swap a with b), one per line.')

    args = parser.parse_args()

    swaplist = []
    # Setup a list of swap 2-tuples
    with open(args.list_file,'r') as list_file:
        lines = list_file.readlines()
        for _,line in enumerate(lines):
            values = line.strip().split(' ')
            if len(values) != 2:
                # we skip this line
                continue
            else:
                swaplist.append(values)
    
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