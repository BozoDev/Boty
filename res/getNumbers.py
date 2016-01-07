#!~/CocBot/HangoutsBot/bin/python
# Uses a virtenv Python that was used to set up HangoutsBot
#  Goal was to be able to command bot from HO

import cv2, subprocess
from operator import itemgetter
import numpy as np
from matplotlib import pyplot as plt

# If used standalone:
# Grab a screenshot
# params= [ '~/Android/Sdk/platform-tools/adb', 'shell', 'screencap -p', '|', 'sed','s/\r$//', '> /tmp/CoCPy.png' ]
# try:
#   subprocess.check_call(params)
#
# except subprocess.CalledProcessError as e:
#   print("Error in Screengrabber: ".format(e))

# Prepare the images
# params= [ '/usr/bin/convert', '/tmp/CoCPy.png', '-crop', '56x52+32+47', '-strip', '/tmp/CoCPyLoot.png' ] 
# try:
#   subprocess.check_call(params)
# except subprocess.CalledProcessError as e:
#   print("Error in Lootgrabber: ".format(e))
# params= [ '/usr/bin/convert', '/tmp/CoCPy.png', '-crop', '25x34+32+96', '-strip', '/tmp/CoCPyTroph.png' ]
# try:
#   subprocess.check_call(params)
# except subprocess.CalledProcessError as e:
#   print("Error in Trophgrabber: ".format(e))

img_rgb = cv2.imread('/tmp/CoCPyLoot.png')
img_gray = cv2.cvtColor(img_rgb, cv2.COLOR_BGR2GRAY)

i=0
digit=0
digits=[]
trophs=[]
gold=[]
elex=[]
dark=[]

template = cv2.imread('digits/num_0.png',0)
w, h = template.shape[::-1]
res = cv2.matchTemplate(img_gray,template,cv2.TM_CCOEFF_NORMED)
threshold = 0.9
loc = np.where( res >= threshold)
for pt in zip(*loc[::-1]):
  digits.append( (digit, pt[0], pt[1]) )
  # print("0: X={} Y={}".format(pt[0], pt[1]))
  i = i + 1
if i > 0:
  i -= 1
for digit in range( 1, 10 ):
  template = cv2.imread('digits/num_' + format(digit) + '.png',0)
  res = cv2.matchTemplate(img_gray,template,cv2.TM_CCOEFF_NORMED)
  threshold = 0.9
  loc = np.where( res >= threshold)
  for pt in zip(*loc[::-1]):
    digits.append( (digit, pt[0], pt[1]) )
    # print("{}: X={} Y={}".format(digit, pt[0], pt[1]))
    i = i + 1
i=len(digits)-1
while i >= 0:
  # If Y-coord small, then it's gold row - after here we won't need the y coord anymore...
  if digits[i][2] < 20:
    gold.append( (digits[i][0], digits[i][1]) )
  elif digits[i][2] > 30:
    dark.append( (digits[i][0], digits[i][1]) )
  else:
    elex.append( (digits[i][0], digits[i][1]) )
  i-=1

i=0
digit=0
img_rgb = cv2.imread('/tmp/CoCPyTroph.png')
img_gray = cv2.cvtColor(img_rgb, cv2.COLOR_BGR2GRAY)

template = cv2.imread('digits/tro_0.png',0)
w, h = template.shape[::-1]
res = cv2.matchTemplate(img_gray,template,cv2.TM_CCOEFF_NORMED)
threshold = 0.9
loc = np.where( res >= threshold)
for pt in zip(*loc[::-1]):
  trophs.append( (digit, pt[0]) )
  #print("0: X={} Y={}".format(pt[0], pt[1]))
  i = i + 1
if i > 0:
  i -= 1
for digit in range( 1, 10 ):
  template = cv2.imread('digits/tro_' + format(digit) + '.png',0)
  res = cv2.matchTemplate(img_gray,template,cv2.TM_CCOEFF_NORMED)
  threshold = 0.9
  loc = np.where( res >= threshold)
  for pt in zip(*loc[::-1]):
    trophs.append( (digit, pt[0]) )
    #print("{}: X={} Y={}".format(digit, pt[0], pt[1]))
    i = i + 1

# Now sort by x-coord, and we have the correct position in number
gs = sorted(gold, key=itemgetter(1))
es = sorted(elex, key=itemgetter(1))
ds = sorted(dark, key=itemgetter(1))
ts = sorted(trophs, key=itemgetter(1))
i=0
# # Clean up some false pos. - 1 found in 4 when to close after 4
# while i<(len(gs)-1):
#   if ( gs[i][0]==4 and gs[i+1][0]==1 and (gs[i][1] - gs[i+1][1]) < 7 ) or ( gs[i][0]==1 and gs[i+1][0]==8 and (gs[i][1] - gs[i+1][1]) < 2) or ( gs[i][0]==9 and gs[i+1][0]==8 and (gs[i][1] - gs[i+1][1]) < 4 ):
#     if gs[i][0]==4 or gs[i][0]==9:
#       o=1
#     else:
#       o=0
#     print("G-Kicking: {}".format(gs[i+o]))
#     gs.remove( (gs[i+o][0], gs[i+o][1]) )
#   i+=1
# i=0
# while i<(len(es)-1):
#   if ( es[i][0]==4 and es[i+1][0]==1 and (es[i][1] - es[i+1][1]) < 7 ) or ( es[i][0]==1 and es[i+1][0]==8 and (es[i][1] - es[i+1][1]) < 2) or ( es[i][0]==9 and es[i+1][0]==8 and (es[i][1] - es[i+1][1]) < 4):
#     if es[i][0]==4 or es[i][0]==9:
#       o=1
#     else:
#       o=0
#     print("E-Kicking: {}".format(es[i+o]))
#     es.remove( (es[i+o][0], es[i+o][1]) )
#   i+=1

# Finaly, we can build the strings:
g=""
for d, x in gs:
  g+="{}".format(d)
e=""
for d, x in es:
  e+="{}".format(d)
d=""
for n, x in ds:
  d+="{}".format(n)
if len(d) == 0:
  d=0
t=""
for n, x in ts:
  t+="{}".format(n)

print("{} E:{} D:{} {}".format(g, e, d, t))
