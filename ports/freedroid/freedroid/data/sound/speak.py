#!/usr/bin/python
import random
import os
i = 1
file = open("botchat")
data = file.readline()[:-1]
while data != "":
  junk = str(i) + ".wav"
  i = i + 1
  pitchpick = random.randint(1, 10)
  if pitchpick < 3:
    pitch = random.randint(1, 20)
  else:
    pitch = random.randint(50,99)
  speed = 100 + random.randint(1, 40)
  chain = "espeak -p " + str(pitch) + " -s " + str(speed) + " -a 150 -w " + junk + """ " """ + data + """ " """
  os.system(chain)
  os.system("oggenc " + junk)
  os.system("rm " + junk)
  data = file.readline()[:-1]
