#!/bin/bash
pushd ~/CoCerBot >/dev/null
. ./buildings.sh
. ./menues.sh
. ./lib.sh

case "${0##*/}" in
  init)
    _startIt
    sleep 2
    screenShot
    _allResis
    collectAllResis resis[@]
    sleep 1
    rearmAll
    touchScreen $empty1
    ;;
  grab)
    screenShot
    ;;
  raw)
    echo "$1 ${!2} $3 $4"
    $( $1 ${!2} $3 $4 )
    ;;
  *)
    exit 1
    ;;
esac
popd >/dev/null
