#!/bin/bash

DEBUG=1

_sdk="/home/keith/Android/Sdk"
_adb="${_sdk}/platform-tools/adb"
_tmpDir="/var/tmp/CoCBot"

cx=1
cy=1
cor=0
# Moved to menues.sh
. ./menues.sh
# # vals for 640x400
# empty1="620 181"
# # 640x400:wake1="210 240"
# wake1="235 270"
# upgrade1="322 348"
# upgrade2="358 350"
# upgrade5="378 354"
# up_conf1="381 245"
# up_ok1="321 303"
# up_ok2="330 290"
# ok1="321 303"
# ok2="330 290"
# army1="26 310"
# army_camp1="210 331"
# army_camp2="247 331"
# army_camp3="285 331"
# army_room1="352 120"
# army_room2="305 120"
# army_barb="191 201"
# army_arch="261 201"
# army_gian="325 201"
# army_gobl="393 201"
# army_bomb="455 201"

## 640x400:
#startIT_cropper="265x60+165+150"
# 720x450:
startIT_cropper="250x95+170+175"
loot_cropper="56x52+32+47"
trophy_cropper="25x34+32+96"
ownres_cropper="95x51+585+14"
# # vals for 512x320
# empty1="496 105"
# upgrade1="258 279"
# upgrade2="287 280"
# up_conf1="305 196"
# up_ok1="257 243"
# army1="19 249"
# army_camp1="169 265"
# army_camp2="197 265"
# army_room1="282 96"
# army_room2="244 96"
# army_barb="153 161"
# army_arch="209 161"
# army_gian="260 161"
# army_gobl="315 161"
# army_bomb="364 161"

if [ ${#@} -gt 0 ] && [ $DEBUG -gt 1 ];then echo "DEBUG: checking args $@";fi
while [ "A$1" != "A" ]
do
  case "$1" in
    -c)
      shift
      cor=1
      if [ "A$1" == "A" ]
      then
        echo $"Need X value of resolution"
        exit 1
      else
        cx=$( echo "scale=2;$1/512"|bc )
        shift
      fi
      if [ "A$1" == "A" ]
      then
        echo $"Need Y value of resolution"
        exit 1
      else
        cy=$( echo "scale=2;$1/320"|bc )
        shift
      fi
      ;;
    -*)
      echo $"Usage: $0 [-c X Y]"
      echo $" -c X Y      where X and Y are the target resolution 1024x640 would be \"-c 1024 640\""
      exit 1
      ;;
    *)
      break
  esac
done

scaler() {
  local _x=$1
  shift
  local _y=$1

  _x=$( echo "$_x*$cx"|bc )
  _x=${_x%.*}
  _y=$( echo "$_y*$cy"|bc )
  _y=${_y%.*}
  echo "$_x $_y"
}

if [ $cor -gt 0 ]
then
  empty1="$( scaler $empty1 )"
  if [ $DEBUG -gt 0 ];then echo "empty1=\"$empty1\"";fi
  upgrade1="$( scaler $upgrade1 )"
  if [ $DEBUG -gt 0 ];then echo "upgrade1=\"$upgrade1\"";fi
  upgrade2="$( scaler $upgrade2 )"
  if [ $DEBUG -gt 0 ];then echo "upgrade2=\"$upgrade2\"";fi
  up_conf1="$( scaler $up_conf1 )"
  if [ $DEBUG -gt 0 ];then echo "up_conf1=\"$up_conf1\"";fi
  up_ok1="$( scaler $up_ok1 )"
  if [ $DEBUG -gt 0 ];then echo "up_ok1=\"$up_ok1\"";fi
  army1="$( scaler $army1 )"
  if [ $DEBUG -gt 0 ];then echo "army1=\"$army1\"";fi
  army_camp1="$( scaler $army_camp1 )"
  if [ $DEBUG -gt 0 ];then echo "army_camp1=\"$army_camp1\"";fi
  army_camp2="$( scaler $army_camp2 )"
  if [ $DEBUG -gt 0 ];then echo "army_camp2=\"$army_camp2\"";fi
  army_room1="$( scaler $army_room1 )"
  if [ $DEBUG -gt 0 ];then echo "army_room1=\"$army_room1\"";fi
  army_room2="$( scaler $army_room2 )"
  if [ $DEBUG -gt 0 ];then echo "army_room2=\"$army_room2\"";fi
  army_barb="$( scaler $army_barb )"
  if [ $DEBUG -gt 0 ];then echo "army_barb=\"$army_barb\"";fi
  army_arch="$( scaler $army_arch )"
  if [ $DEBUG -gt 0 ];then echo "army_arch=\"$army_arch\"";fi
  army_gian="$( scaler $army_gian )"
  if [ $DEBUG -gt 0 ];then echo "army_gian=\"$army_gian\"";fi
  army_gobl="$( scaler $army_gobl )"
  if [ $DEBUG -gt 0 ];then echo "army_gobl=\"$army_gobl\"";fi
  army_bomb="$( scaler $army_bomb )"
  if [ $DEBUG -gt 0 ];then echo "army_bomb=\"$army_bomb\"";fi
fi

_logger() { 
###
# Prints parameters passed to outf
#   outf should be a pipe
#
# Params:
#
#   [N]                     N is minimum required debug-level to actually output something (optional)
#   "This is" a string | -  Text to log to outf or take from stdin (pipe)
# 

  local outf="./CoCer" cmnd="exit" d=0
  while [ ${#@} -gt 0 ]
  do
    case "$1" in
      "-" )
        cmnd="cat"
        shift
        ;;
      [0-9] )
        d=$1
        shift
        ;;
      *)
        cmnd="echo \"$@\""
        break
        ;;
    esac
  done
  if [ $d -le $DEBUG ]
    then
    $cmnd >>$outf 2>&1
  fi
}

_compareImages() {
  local pic1="$1" pic2="$2"
  lib/perceptualdiff "$1" "$2" |_logger 1 -
  return ${PIPESTATUS[0]}
}

_startIt() {
  local r= _errscr=""
  ps ax |grep -v grep |grep adb >/dev/null 2>&1
  r=$?
  if [ $r -gt 0 ]
  then
    _logger "Starting adb..."
    $_adb start-server
  fi
  screenShot
  convert /tmp/CoCNow.png -crop $startIT_cropper -strip /tmp/CoC2Check.png >CoCer
  _compareImages /tmp/CoC2Check.png GoldenImages/Reload-gi.png
  r=$?
  if [ $r -eq 0 ]
  then
    _logger 1 "Found a screen"
    touchScreen $wake1
    sleep 10
  else
    _logger "No Reload screen"
    _logger "Creating /tmp/CoCUnknown-$( date +%H%M )_X.png 4 DEBUG"
    cp /tmp/CoCNow.png "/tmp/CoCUnknown-$( date +%H%M )_1.png"
    cp /tmp/CoC2Check.png "/tmp/CoCUnknown-$( date +%H%M )_2.png"
  fi

}

_allResis() {
  resis=( "$mine1" "$mine2" "$mine3" "$mine4" "$mine5" "$pump1" "$pump2" "$pump3" "$pump4" "$pump5" "$pump6" )
}

_run() {
  _startIt
  _allResis
  collectAllResis resis[@]
  sleep 1
  rearmAll
}

_nowint() {
  local i=$( date +%k )
  if [ $i -gt 0 ]
  then
    echo -ne "$i"
  fi
  date +%M
}

_calibrate() {
  local x1= y1= {h..k}= {o..p}= _tmp
  local builds=($@)
  declare -A X Y
  _logger "Starting calibration"
  _logger "Resis:"
  for ((h=0; h<${#builds[@]};h++ ))
  do
    i="${builds[$h]}"
    _logger "Doing $i - press $i middle approx 3x slowly and hold longish with pauses"
    _presses="$( $_adb shell getevent -qc 25 /dev/input/event0 |grep '0003 000[01] 00000[0-9a-f]*'| sed 's/\r$//' )"
    if [ $DEBUG -gt 0 ];then _logger "DEBUG: Got presses: $_presses";fi
    _IFS="$IFS"
    IFS=$'\n'
    j=0
    k=0
    unset X
    unset Y
    for _tmp in $_presses
    do
      if [[ $_tmp == *"0003 0000 0000"* ]]
      then
        X[$j]="${_tmp##* }"
        let j++
      elif [[ $_tmp == *"0003 0001 0000"* ]]
      then
        Y[$k]="${_tmp##* }"
        let k++
      fi
    done
    IFS="$_IFS"
    x1="$( _avrCoor X[@] )"
    y1="$( _avrCoor Y[@] )"
    if [ $x1 -gt 0 ] && [ $y1 -gt 0 ]
    then
      eval ${i}="\"$x1 $y1\"" #"
      _logger "New coordinates for $i set to ${!i}"
    else
      rerun="$rerun $i"
      let h--
    fi
    for i in ${builds[@]}
    do
      echo "${i}=\"${!i}\""
    done
    sleep 1
  done
}

_avrCoor() {
  local o= p= j=
  local arr=("${!1}")
  if [ ${#arr[@]} -gt 1 ]
  then
    _logger "Averageing $1"
    for ((j=0; j<${#arr[@]}; j++ ))
    do
      o=$((16#${arr[$j]}))
      p=$(( p + o ))
    done
    echo "$(( p / j ))"
  else
    echo "$((16#${arr[0]}))"
  fi
  
}
# Press Key at x=39,y=262
#$_adb shell sendevent /dev/input/event0 3 0 39
#$_adb shell sendevent /dev/input/event0 3 1 262
#$_adb shell sendevent /dev/input/event0 1 330 1
#$_adb shell sendevent /dev/input/event0 0 0 0
#$_adb shell sendevent /dev/input/event0 1 330 0
#$_adb shell sendevent /dev/input/event0 0 0 0
# Output from press 'Reload'
#/dev/input/event0: 0003 0000 0000016c
#/dev/input/event0: 0000 0000 00000000
#/dev/input/event0: 0003 0001 00000164
#/dev/input/event0: 0000 0000 00000000
#/dev/input/event0: 0001 014a 00000001
#/dev/input/event0: 0000 0000 00000000
#/dev/input/event0: 0001 014a 00000000
#/dev/input/event0: 0000 0000 00000000
#
#DragPress:
# 0003 0000 0000007c
# 0000 0000 00000000
# 0003 0001 000001ac
# 0000 0000 00000000
# 0001 014a 00000001
# 0000 0000 00000000
# 0003 0000 0000007f
# 0000 0000 00000000
# 0003 0001 000001a9
# 0000 0000 00000000
# 0003 0000 00000082
# 0000 0000 00000000
# 0003 0001 000001a6
# 0000 0000 00000000
# 0003 0000 00000083
# 0000 0000 00000000
# 0003 0001 000001a5
# 0000 0000 00000000
# 0003 0000 00000084
# 0000 0000 00000000
# 0003 0000 00000085
# 0000 0000 00000000
# 0003 0001 000001a4
# 0000 0000 00000000
# 0003 0000 00000086
# 0000 0000 00000000
# 0003 0001 000001a3
# 0000 0000 00000000
#  [...] 
# 0003 0000 00000127
# 0000 0000 00000000
# 0003 0001 00000136
# 0000 0000 00000000
# 0003 0000 00000128
# 0000 0000 00000000
# 0001 014a 00000000
# 0000 0000 00000000

touchScreen() {
  local x=$1
  shift
  local y=$1
  _logger 1 "DEBUG: touching @ ${x}x${y}"
  if [ $cor -gt 0 ]
  then
    x=$( echo "$x*$cx"|bc )
    x=${x%.*}
    y=$( echo "$y*$cy"|bc )
    y=${y%.*}
    _logger 1 "DEBUG: touching @ ${x}x${y} due to correction of cx=$cx cy=$cy"
  fi
  $_adb shell sendevent /dev/input/event0 3 0 $x
  $_adb shell sendevent /dev/input/event0 3 1 $y
  $_adb shell sendevent /dev/input/event0 1 330 1
  $_adb shell sendevent /dev/input/event0 0 0 0
  $_adb shell sendevent /dev/input/event0 1 330 0
  $_adb shell sendevent /dev/input/event0 0 0 0
  sleep 0.5
}

_touchScreenM() {
  local x=$1
  shift
  local y=$1
  shift
  local i=$1
  local o
  for (( o=0; o<i; o++ ))
  do
    $_adb shell sendevent /dev/input/event0 3 0 $x
    $_adb shell sendevent /dev/input/event0 3 1 $y
    $_adb shell sendevent /dev/input/event0 1 330 1
    $_adb shell sendevent /dev/input/event0 0 0 0
    $_adb shell sendevent /dev/input/event0 1 330 0
    $_adb shell sendevent /dev/input/event0 0 0 0
  done
  sleep 0.1
}

touchScreenM() {
  local x=$1 y=$2 i=$3 o
  rm -f /tmp/touchm.tmp
  for (( o=0; o<i; o++ ))
  do
    echo "3 0 $x">>/tmp/touchm.tmp
    echo "3 1 $y">>/tmp/touchm.tmp
    echo "1 330 1">>/tmp/touchm.tmp
    echo "0 0 0">>/tmp/touchm.tmp
    echo "1 330 0">>/tmp/touchm.tmp
    echo "0 0 0">>/tmp/touchm.tmp
  done
  $_adb push /tmp/touchm.tmp /data/ >/dev/null 2>&1
  $_adb shell "cat /data/touchm.tmp|while read i;do sendevent /dev/input/event0 \$i;done"
}

_dragScreen() {
# Old and slow...
  local xs=( $( eval echo {$1..$2} ) ) ys=( $( eval echo {$3..$4} ) ) i=0
  xn=$(( $1 - $2 ))
  $_adb shell sendevent /dev/input/event0 3 0 ${xs[$i]}
  $_adb shell sendevent /dev/input/event0 3 1 ${ys[$i]}
  $_adb shell sendevent /dev/input/event0 1 330 1
  $_adb shell sendevent /dev/input/event0 0 0 0
  while [ $i -lt ${#xs[@]} ] && [ $i -lt ${#ys[@]} ]
  do
    $_adb shell sendevent /dev/input/event0 3 0 ${xs[$i]}
#    $_adb shell sendevent /dev/input/event0 0 0 0
    $_adb shell sendevent /dev/input/event0 3 1 ${ys[$i]}
#    $_adb shell sendevent /dev/input/event0 0 0 0
    let i+=5
  done
  $_adb shell sendevent /dev/input/event0 1 330 0
  $_adb shell sendevent /dev/input/event0 0 0 0

}

dragScreen() {
  local x=$1 y=$3
  local xn=$(( ($2 - $1) / 10 ))
  local yn=$(( ($4 - $3) / 10 ))
  echo "3 0 $x" >/tmp/dragger.tmp
  echo "3 1 $y" >>/tmp/dragger.tmp
  echo "1 330 1" >>/tmp/dragger.tmp
  for (( i=0; i<10; i++ ))
  do
    let x+=xn
    let y+=yn
    echo "3 0 $x" >>/tmp/dragger.tmp
    echo "0 0 0" >>/tmp/dragger.tmp
    echo "3 1 $y" >>/tmp/dragger.tmp
    echo "0 0 0" >>/tmp/dragger.tmp
  done
  echo "1 330 0" >>/tmp/dragger.tmp
  echo "0 0 0" >>/tmp/dragger.tmp
  $_adb push /tmp/dragger.tmp /data/ >/dev/null
  $_adb shell "cat /data/dragger.tmp|while read i;do sendevent /dev/input/event0 \$i;done"
}

touchScreenMFingers() {

#   ABS (0003): 002f  : value 0, min 0, max 9, fuzz 0, flat 0, resolution 0
#               0030  : value 0, min 0, max 31, fuzz 0, flat 0, resolution 0
#               0035  : value 0, min 0, max 1279, fuzz 0, flat 0, resolution 0
#               0036  : value 0, min 0, max 2111, fuzz 0, flat 0, resolution 0
#               0039  : value 0, min 0, max 65535, fuzz 0, flat 0, resolution 0
#               003a  : value 0, min 0, max 255, fuzz 0, flat 0, resolution 0
# is:
#   ABS (0003): ABS_MT_SLOT           : value 1, min 0, max 9, fuzz 0, flat 0, resolution 0
#               ABS_MT_TOUCH_MAJOR    : value 0, min 0, max 31, fuzz 0, flat 0, resolution 0
#               ABS_MT_POSITION_X     : value 0, min 0, max 1279, fuzz 0, flat 0, resolution 0
#               ABS_MT_POSITION_Y     : value 0, min 0, max 2111, fuzz 0, flat 0, resolution 0
#               ABS_MT_TRACKING_ID    : value 0, min 0, max 65535, fuzz 0, flat 0, resolution 0
#               ABS_MT_PRESSURE       : value 0, min 0, max 255, fuzz 0, flat 0, resolution 0
  local x=${empty1% *}
  local y=${empty1#* }
  local i
  local x1=$1
  shift
  local y1=$1
  shift
  local x2=$1
  shift
  local y2=$1
  shift
  local n=$1
  for (( i=0; i<n; i++ ))
  do
    $_adb shell sendevent /dev/input/event0 3 47 0
    if [ $i -eq 0 ];then $_adb shell sendevent /dev/input/event0 3 48 15 ;echo "init empty: ${x} ${y}";fi
    $_adb shell sendevent /dev/input/event0 3 58 110
    $_adb shell sendevent /dev/input/event0 3 53 $x1
    $_adb shell sendevent /dev/input/event0 3 54 $y1
    $_adb shell sendevent /dev/input/event0 3 47 1
    $_adb shell sendevent /dev/input/event0 3 58 110
    $_adb shell sendevent /dev/input/event0 3 53 $x2
    $_adb shell sendevent /dev/input/event0 3 54 $y2
    $_adb shell sendevent /dev/input/event0 0 0 0
    (( x1++, y1--, x2--, y2++ ))
  done
  $_adb shell sendevent /dev/input/event0 3 47 0
  $_adb shell sendevent /dev/input/event0 3 48 14
  $_adb shell sendevent /dev/input/event0 3 58 110
  $_adb shell sendevent /dev/input/event0 3 53 $x
  $_adb shell sendevent /dev/input/event0 3 54 $y
  $_adb shell sendevent /dev/input/event0 0 0 0

}

screenShot() {
  $_adb shell screencap -p | sed 's/\r$//' > /tmp/CoCNow.png
}

stayOnline() {
  local n=
  for (( n=$1; n>0; n-- ))
  do
    touchScreen $empty1
    sleep 47
  done
}

stayOnlineTime() {
  local t=$1 n= r=
  while [ $( _nowint ) -lt $t ]
  do
    stayOnline 5
    screenShot
    n=$( _nowint )
    cp /tmp/CoCNow.png ${_tmpDir}/${n}-onlineStayer.png
    if [ -s /tmp/OnlineLast.png ]
    then
      _compareImages /tmp/CoCNow.png /tmp/OnlineLast.png 2>&1 |_logger -
      r=${PIPESTATUS[0]}
      if [ $r -eq 0 ]
      then
        _logger "Trouble... no screenchange detected"
        cp /tmp/OnlineLast.png ${_tmpDir}/${n}-OnlineLast.png
        cp /tmp/CoCNow.png ${_tmpDir}/${n}-OnlineCurrent.png
        _findScreen ${_tmpDir}/${n}-OnlineCurrent.png
      fi
    else
      _logger "Couldn't find last Screenshot - assuming first run..."
    fi
    mv /tmp/CoCNow.png /tmp/OnlineLast.png
  done
}

_cropper() {
  local _img="" _area="$1"
  if [ "A$2" == "A" ]
  then
    _img="/tmp/CoCNow.png"
  else
    _img="$2"
  fi
  convert "$_img" -crop $_area -strip /tmp/CoCCrop.png | _logger -
  return ${PIPESTATUS[0]}
}

_myResis() {
  local myR g e
  screenShot
  _cropper "$ownres_cropper"
  rm -f /tmp/CoCPyLoot.png
  ln -s /tmp/CoCCrop.png /tmp/CoCPyLoot.png
  pushd GraphicalRecogn/Loot >/dev/null
  myR="$( ./tester.py )"
  g="${myR%% *}"
  e="${myR#*D:}"
  e="${e%% *}"
  popd >/dev/null
  echo "$g $e"
}

_findScreen() {
  local _screen="$1" i= r= standardErrors="$( ls -1 GoldenImages/*-gi.png )"
  for i in "$standardErrors"
  do
    convert "$_screen" -crop 265x60+165+150 -strip /tmp/CoC2Check.png | _logger -
    _compareImages /tmp/CoC2Check.png $i |_logger -
    r=${PIPESTATUS[0]}
    if [ $r -eq 0 ]
    then
      _logger "Identified as $i"
      i="${i##*/}"
      i="${i%-*}"
      echo "$i"
      return 0
    else
      if [ $DEBUG -gt 0 ];then _logger "No match on $i" ;fi
    fi
  done
  rm /tmp/CoC2Check.png
}

rearmAll() {
  touchScreen $townhall
  touchScreen $upgrade3_3
  touchScreen $army_del_ok2
  sleep 0.5
}

selectBuilding() {
  local x=$1
  shift
  local y=$1
  touchScreen $x $y
}

selectBuildingOption() {
  local elements=$1
  shift
  local item=$1
  local x y i
  case "$elements" in
    2)
      x=330
      ;;
    3)
      x=300
      ;;
    4)
      x=300
      ;;
    5)
      x=275
      ;;
    *)
      x=450
      ;;
    esac
    y=390
    touchScreen $(( x+item*(30+item*2) )) $y
# Not quite sure if I had adjusted this to new layout
# found these in case need to revert:
# 2 300
# factor 25
# y 350
}

upgradeBuilding() {
# Pump 345 88
  local x=$1
  shift
  local y=$1
  shift
  selectBuilding $x $y
  sleep 1
  screenShot
  mv /tmp/CoCNow.png ${_tmpDir}/${x}-${y}-CoCNow-B-Select.png
  selectBuildingOption $1 $2
  screenShot
  mv /tmp/CoCNow.png ${_tmpDir}/${x}-${y}-CoCNow-B-Select-Upgrade.png
  sleep 1
  touchScreen $ok1
  screenShot
  mv /tmp/CoCNow.png ${_tmpDir}/${x}-${y}-CoCNow-B-UpgradeOK.png
  sleep 2
  touchScreen $empty1
}

upgradeBarak() {
  local x=$1
  shift
  local y=$1
  shift
  selectBuilding $x $y
  screenShot
  mv /tmp/CoCNow.png ${_tmpDir}/${x}-${y}-CoCNow-B-Select.png
  selectBuildingOption 5 4
  screenShot
  mv /tmp/CoCNow.png ${_tmpDir}/${x}-${y}-CoCNow-B-Select-Upgrade.png
  touchScreen $ok2
  screenShot
  mv /tmp/CoCNow.png ${_tmpDir}/${x}-${y}-CoCNow-B-UpgradeOK.png
  touchScreen $empty1
}

upgradeWallRow() {
  # 106 75
  local x=$1
  shift
  local y=$1
  touchScreen $x $y
  screenShot
  mv /tmp/CoCNow.png ${_tmpDir}/${x}-${y}-CoCNow-WR-Select.png
  # 106 75
  touchScreen $upgrade1
  screenShot
  mv /tmp/CoCNow.png ${_tmpDir}/${x}-${y}-CoCNow-WR-Select-Row.png
  touchScreen $upgrade2
  screenShot
  mv /tmp/CoCNow.png ${_tmpDir}/${x}-${y}-CoCNow-WR-Select-Upgrade.png
  touchScreen $up_conf1
  screenShot
  mv /tmp/CoCNow.png ${_tmpDir}/${x}-${y}-CoCNow-WR-Upgrade-realy.png
  touchScreen $up_ok1
  screenShot
  mv /tmp/CoCNow.png ${_tmpDir}/${x}-${y}-CoCNow-WR-UpgradeOK.png
}

upgradeResi() {
  local x=$1
  shift
  local y=$1
  touchScreen $x $y
  screenShot
  mv /tmp/CoCNow.png $_tmpDir/${x}-${y}-CoCNow-UR-$( date +%H%M ).png
  touchScreen $upgrade5
  screenShot
  mv /tmp/CoCNow.png $_tmpDir/${x}-${y}-CoCNow-URS-$( date +%H%M ).png
  touchScreen $up_ok2
  screenShot
  mv /tmp/CoCNow.png $_tmpDir/${x}-${y}-CoCNow-URO-$( date +%H%M ).png
  sleep 1
  touch $empty1
}

collectResis() {
  local x=$1
  shift
  local y=$1
  touchScreen $x $y
  sleep 1
  touchScreen $empty1
}

collectAllResis() {
  local i
  local _res=("${!1}")

  for ((i=0;i<${#_res[@]};i++))
  do
    touchScreen ${_res[$i]}
    touchScreen $empty1
    sleep 1
  done
}

collectAllGivenResis() {
  local x y
  while [ "A$1" != "A" ]
  do
    x=$1
    shift
    y=$1
    shift
    touchScreen $x $y
    sleep 1
    touchScreen $empty1
    sleep 1
  done
}

collectLoot() {
  touchScreen $castle
  touchScreen $upgrade5_5
  touchScreen $up_conf1
}

buildArmy() {
###
# Build an Army with same in every barrack
#
# army1 =  small left Army-Organizer
#
# Params:
#   N           int N is amount of barracks to use
#   UNIT AMNT   How many to build of what (e.g.:
#                   buildArmy 3 $army_arch 30 $army_barb 20
#               would create 30 Archers and 20 Babarian in all 3 Barracks
#               (150 units all in all)
# TODO: this actualy passes the unit in x y coordinates - change to unit name and use reference via ${!unit}
#       half done - remove extra locals
  local i xy n c o camp
  touchScreen $army1
  c=$1
  shift
  for (( o=1; o<=c; o++ ))
  do
    camp=army_camp$o
    touchScreen ${!camp}
    _logger 1 "Next call tSM with ${!i} $n"
    for (( i=1; i<${#@}; i+=2 ))
    do
      let n=i+1
      xy=${!i}
      _logger 1 "calling tSM with ${!xy} ${!n}"
      touchScreenM ${!xy} ${!n}
    done
  done
}

buildArmyB() {
###
# Build an Army with in a specific barrack
#
# army1 =  small left Army-Organizer
#
# Params:
#   N           int N is the barracks to use
#   UNIT AMNT   How many to build of what (e.g.:
#                   buildArmy 3 $army_arch 30 $army_barb 20
#               would create 30 Archers and 20 Babarian in all 3 Barracks
#               (150 units all in all)
# TODO: this actualy passes the unit in x y coordinates - change to unit name and use reference via ${!unit}
#       half done - remove extra locals
  local xy n c o camp
  touchScreen $army1
  c=$1
  shift
  camp=army_camp$c
  touchScreen ${!camp}
  for (( i=1; i<${#@}; i+=2 ))
  do
    let n=i+1
    xy=${!i}
    _logger 1 "DEBUG: Calling tSM with ${!xy} ${!n}"
    touchScreenM ${!xy} ${!n}
  done
}

emptyBarracks() {
  local c camp
  touchScreen $army1
  for (( c=1; c<=3; c++ ))
  do
    camp=army_camp$c
    touchScreen ${!camp}
    touchScreenM $army_room1 10
  done
  touchScreen $empty1
}

requestTroops() {
  touchScreen $army1
  sleep 0.5
  touchScreen $army_req1
  sleep 1
  touchScreen $army_req2
  touchScreen $empty1           
}

_attack() {
  local nexts=$(( ( RANDOM % 10 )  + 1 )) dropzone="220 330" r t _t

  touchScreen $attack1
  sleep 0.5
  touchScreen $attack2
  screenShot
  convert /tmp/CoCNow.png -crop 230x145+245+150 -strip /tmp/CoC2Check.png | _logger 1 -
  r= $(_compareImages /tmp/CoC2Check.png GoldenImages/Attack-Shield-gi.png )
  r=$?
  if [ $r -eq 0 ]
  then
    touchScreen $attack3
  fi
  nexts=1
  while [ $nexts -gt 0 ]
  do
    touchScreen $attack_next
    sleep 6
    screenShot
    cp /tmp/CoCNow.png /tmp/CoCEnemy-$( date +%H%M ).png
    convert /tmp/CoCNow.png -crop $loot_cropper -strip /tmp/CoCPyLoot.png
    convert /tmp/CoCNow.png -crop $trophy_cropper -strip /tmp/CoCPyTroph.png
    pushd GraphicalRecogn/Loot >/dev/null
    loot="$( ./tester.py )"
    popd >/dev/null
    gold=${loot%% *}
    elex=${loot#*E:}
    elex=${elex%% *}
    dark=${loot#*D:}
    dark=${dark%% *}
    trophy=${loot##* }
    _logger 1 "Found loot Gold: $gold Elexir: $elex Dark: $dark Trophies: $trophy"
    if [ $gold -gt 10000 ] && [ $elex -gt 30000 ] && [ $trophy -lt 20 ] && [ $dark -eq 0 ]
    then
      nexts=0
    fi
#    let nexts--
  done
  dragScreen 240 350 300 190
  # Giant:
  touchScreen 260 417
  touchScreenM $dropzone 10
  sleep 3
  # Bomber:
  touchScreen 310 416
  touchScreen $dropzone
  sleep 0.5
  touchScreen $dropzone
  sleep 1.5
  touchScreen $dropzone
  # Barbs:
  touchScreen 110 415
  touchScreenM $dropzone 12
  # CB:
  touchScreen 360 416
  touchScreen $dropzone
  # Barbs:
  touchScreen 110 415
  # touchScreenM 160 250 17
  y=200
  for (( x=130;x<230;x+=6 ))
  do
    touchScreen $x $y
    let y+=7
  done
  touchScreenM 260 360 10
  # Arch:
  touchScreen 160 415
  touchScreenM $dropzone 18
  touchScreenM 180 250 22
  sleep 7
  # Gobblins:
  touchScreen 210 416
  touchScreenM $dropzone 24
  #empty 'em
  touchScreen 160 415
  touchScreenM $dropzone 20
  touchScreen 110 415
  touchScreenM $dropzone 20
  touchScreen 310 416
  touchScreenM $dropzone 20
  touchScreen 260 417
  touchScreenM $dropzone 20
  t=$( date +%k%M --date '+ 3 minutes' )
  while [ $( _nowint ) -le $t ]
  do
    screenShot
    convert /tmp/CoCNow.png -crop 90x35+315+355 -strip /tmp/CoCAtt.png
    r= $(_compareImages /tmp/CoCAtt.png GoldenImages/AttackFinished-gi.png )
    r=$?
    if [ $r -eq 0 ]
    then
      _logger 1 "$( date +%H%M)-Attack stopped running..."
      sleep 2
      break
    else
      _logger 1 "$( date +%H%M ) since $t - Pic differs - assuming on ground fights..."
    fi
    mv /tmp/CoCNow.png /tmp/CoCAttackRunning.png
    sleep 5
    # touchScreen $empty1
  done

# buildArmy 3 army_gian 3 army_arch 12 army_barb 12 army_bomb 1 - army_gobl 5
}

shareLastAttack() {
    touchScreen $log1
    touchScreen $log_attack
    touchScreen $log_attShare
    touchScreen $log_attShare_ok
    touchScreen $empty1
}

shareLastDefense() {
    touchScreen $log1
#    touchScreen $log_attack
    touchScreen $log_attShare
    touchScreen $log_attShare_ok
    touchScreen $empty1
}

_warPath() {
  local t d=$1

  while [ $( date +%k%M ) -lt $d ]
  do
    _logger 1 "Starting attack"
    _attack
    screenShot
    mv /tmp/CoCNow.png attack/$( date +%H%M )attack-result.png
    touchScreen 360 370
    sleep 2
    screenShot
    mv /tmp/CoCNow.png attack/$( date +%H%M )attack-post.png
    shareLastAttack
    sleep 3
    requestTroops
    sleep 1
    t=$( date +%k%M )
    t=$(( t + 35 ))
    stayOnlineTime $t
    touchScreen $empty1
    stayOnline 4
    emptyBarracks
    sleep 0.5
    buildArmy 3 army_gian 3 army_arch 14 army_gobl 7 army_barb 14 army_bomb 1
    touchScreen $empty1
    sleep 120
    screenShot
    mv /tmp/CoCNow.png attack/$( date +%H%M )attack-final.png
    collectAllResis resis[@]
  done
}
