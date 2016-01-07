#!/bin/bash

DEBUG=0
tmp="/var/tmp/CoCBot"
res="720 450"

## Buildings:
wake1="235 270"
empty1="708 229"
townhall="330 180"
castle="280 135"
mine1="242 193"
mine2="377 316"
mine3="590 370"
mine4="570 290"
mine5="645 195"
pump1="475 156"
pump2="536 189"
pump3="610 260"
pump4="525 100"
pump5="350 400"
pump6="640 330"
estore1="390 145"
estore2="465 280"
gstore1="450 190"
gstore2="491 222"
archer1="330 120"
archer2="283 219"
archer3="530 255"
canon1="420 120"
canon2="520 330"
canon3="305 50"
mortar1="390 245"
wizard1="570 230"
flak1="315 270"
lab1="80 140"
barrack1="180 315"
barrack2="480 50"
barrack3="600 135"
spell1="170 80"
camp1="120 255"
camp2="270 365"
camp3="445 380"
## Menu Icons:
army1="26 345"

_allResis() {
  resis=( "$mine1" "$mine2" "$mine3" "$mine4" "$mine5" "$pump1" "$pump2" "$pump3" "$pump4" "$pump5" "$pump6" )
}
