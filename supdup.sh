#!/bin/bash
# Syntax: ./supdup <directory to analyze> <minimum file size for dedup check>
scandir="$1"
! [[ -d "$1" ]] && echo -e "'$1' is not a valid directory." && exit

! [[ -d supadupa ]] && mkdir supadupa
! [[ -d supadupa ]] && echo -e "Failed to create log dir" && exit

[[ -z "$2" ]] && sizefilter="0" || sizefilter="$2"

logdir="supadupa/$(date +%Y_%m_%d_%H-%M-%S)"
mkdir "$logdir"
mkdir "$logdir/sum"
mkdir "$logdir/size"
mkdir "$logdir/sizenames"
touch "$logdir/dupes.txt"
touch "$logdir/dupes.txt"

DEF="\x1b[0m"
GRAY="\x1b[37;0m"
LIGHTBLACK="\x1b[30;01m"
DARKGRAY="\x1b[30;11m"
LIGHTBLUE="\x1b[34;01m"
BLUE="\x1b[34;11m"
LIGHTCYAN="\x1b[36;01m"
CYAN="\x1b[36;11m"
LIGHTGRAY="\x1b[37;01m"
WHITE="\x1b[37;11m"
LIGHTGREEN="\x1b[32;01m"
GREEN="\x1b[32;11m"
LIGHTMAGENTA="\x1b[35;01m"
MAGENTA="\x1b[35;11m"
LIGHTRED="\x1b[31;01m"
RED="\x1b[31;11m"
LIGHTYELLOW="\x1b[33;01m"
YELLOW="\x1b[33;11m"

dupes_found=0

get_filesize(){
  stat -f%z "${1}"
}

get_sum(){
  cksum "${1}" | cut -f1 -d' '
}

trap_handler(){
  display_results | tee "$logdir/results.txt" 
}

display_results(){
  echo -e
  echo -e "Scan ended!"
  echo -e
  echo -e "---- SUPDUP RESULTS ----"
  echo -e
  echo -e "Duration: $starttime -> $(date)"
  echo -e "Dir: $scandir"
  echo -e "Filesize filter: $sizefilter bytes"
  echo -e "Duplicates found: $dupes_found"
  if [[ "$dupes_found" -gt 0 ]]; then
    echo -e
    while read dupe; do
      dupes=$(echo -e $(cat $dupe | wc -l))
      dupesize=$(( dupes / 1000000))
      echo -e "-- $dupe: $dupes duplicates (~ $dupesize MB ) --"
      cat "$dupe"
    done<"$logdir/dupes.txt"
  fi
  echo -e
  echo -e "------------------------"
  tput sgr0
  exit
}

recursec() {
 for i in "$1"/*; do
  if [[ "$i" != *supadupa* ]]; then
    if [[ -d "$i" ]]; then
      local dirc="$(tput setaf $(( ( RANDOM % 255 )  + 1 )))"
      echo -e -n "${dirc}>${DEF}" 
      recursec "$i"
      echo -e -n "${dirc}<${DEF}"
    elif [[ -f "$i" ]]; then
      size=$(get_filesize "$i")
      if [[ "$size" -gt "$sizefilter" ]]; then
        if [[ -f "$logdir/size/$size" ]]; then
          crcsum="$(get_sum "$i")"
            if [[ -f "$logdir/sum/$crcsum" ]]; then
              echo -e -n "${LIGHTGREEN}!${DEF}"
              echo -e "$i" >> "$logdir/sum/$crcsum"
              echo -e "$size" >> "$logdir/sum/$crcsum.size"
              grep --silent "$crcsum" "$logdir/dupes.txt"
              if [[ "$?" -ne 0 ]]; then
                echo -e "$logdir/sum/$crcsum" >> "$logdir/dupes.txt"
                (( dupes_found++ ))
              fi
            else
              echo -e -n "${DARKGRAY}.${DEF}"
              echo -e "$i" >> "$logdir/sum/$crcsum"
            fi
        else      
          echo -e -n "${DARKGRAY}.${DEF}"
          echo -e "$i" >> "$logdir/size/$size"
        fi
      fi
    fi
  fi 
 done
}

trap trap_handler EXIT SIGTERM SIGKILL
starttime="$(date)"
recursec "$scandir"
