#!/bin/bash

#progname=`basename $0`
progname=$(basename $0)
videobitrate=1331200

# for 16:9 TV capturing
# aspect=16:9
# ssize=640x360

# for 4:3 TV capturing
# aspect=4:3
# ssize=640x480

# If none command line arguments are given, or if -h is given as first argument, show some help
if [[ $1 == "" || $1 == "-h" ]]; then
  echo "Usage:"
  echo "$progname <file.m2t> [aspect_ratio]"
  echo "If aspect_ratio parameter is set to 4 or 4:3, then 4:3 aspect ratio will be used for output streams."
  echo "If aspect_ratio parameter is set to 16 or 16:9, then 16:9 aspect ratio will be used for output streams."
  echo "If aspect_ratio parameter is not set, then aspect ratio will be autodetected from input stream."
  exit 0
fi


if [[ $2 == "16" || $2 == "16:9" ]]; then
  aspect=16:9
  ssize=640x360
  printf "\n"
  echo "16:9 mode"
  printf "\n"
fi

if [[ $2 == "4" || $2 == "4:3" ]]; then
  aspect=4:3
  ssize=640x480
  printf "\n"
  echo "4:3 mode"
  printf "\n"
fi

filename="$1"

if [ ! $2 ]; then
  printf "\n"
  echo -en "\\033[1;32mAspect ratio autodetect mode: "
  aspect=$(ffprobe -i "$filename" -show_streams -pretty 2>&1 | grep display_aspect_ratio | cut -d'=' -f2)
  echo -n $aspect
  echo -e "\\033[0;39m"
  printf "\n"
  case "$aspect" in
    16:9)
      ssize=640x360
      ;;
    4:3)
      ssize=640x480
      ;;
  esac
fi

filenamewithoutext="${filename%%.*}"

mpgext=".mpg"
aviext=".avi"
mpgout="$filenamewithoutext$mpgext"
aviout="$filenamewithoutext$aviext"
#if [ ! -f "$mpgout" ]; then
#  echo "Stage 1 (to PAL-DVD MPG), processing file: $filename to $mpgout"
#  printf "\n"
  #ffmpeg -y -i "$filename" -target pal-dvd -g 15 -b 6000000 -maxrate 9000000 -minrate 0 -bufsize 1835008 -packetsize 2048 -muxrate 10080000 -b:a 448000 -aspect $aspect -s 720x576 -b 5000k -b:a 320k -y -mbd rd -trellis 2 -cmp 2 -subcmp 2 -threads 2 "$mpgout"
#  ffmpeg -y -i "$filename" -aspect $aspect -target pal-dvd -vcodec copy -acodec copy "$mpgout"
#  sync
#  printf "\n"
#fi

#if [ -f "$mpgout" ]; then
#  printf "\n"
#  echo "Stage 2 (to AVI), processing $mpgout to $aviout"
#  printf "\n"
#  ffmpeg -y -i "$mpgout" -vtag DIVX -f avi -vcodec mpeg4 -aspect $aspect -s $ssize -b:v $videobitrate -acodec libmp3lame -b:a 128000 -ar 44100 -ac 2 "$aviout"
#  printf "\n"
#fi

ffmpeg -y -i "$filename" -aspect $aspect -target pal-dvd -vcodec copy -acodec copy - | ffmpeg -y -i - -vtag DIVX -f avi -vcodec mpeg4 -aspect $aspect -s $ssize -b:v $videobitrate -acodec libmp3lame -b:a 128000 -ar 44100 -ac 2 "$aviout"

