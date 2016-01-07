#!/bin/bash

avd="CoCBot"
export STUDIO_JDK="/usr/java/latest"
export JAVA_HOME="$STUDIO_JDK"

while [ ${#@} -gt 0 ]
do
  case $1 in
    -o)
      # Enable output and input xTerms
      alias a="echo a > CoCerIn"
      alias y="echo y > CoCerIn"
      alias n="echo n > CoCerIn"
      xterm -fg green -bg black -bd green -title "CoCerBot Input" -e "/bin/bash" &
      xterm -fg green -bg black -bd green -title "CoCerBot Output" -e "tail -f CoCer" &
      shift
      ;;
    -h)
      echo "Usage: $0 [-h] [-o]"
      echo "-h      this help screen"
      echo " -o     start xTerms in background for in-&output"
      exit 1
      ;;
    *)
      avd="$1"
      ;;
  esac
done
#  avd="N5_44"
pushd ~/Android/Sdk
tools/emulator -avd $avd -gpu on -verbose -no-boot-anim -noaudio -qemu -m 1200
# -qemu -m 2048 -enable-kvm
popd
