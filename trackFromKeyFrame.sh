#!/bin/bash
# Given a bounding box and its timestamp run cmt object tracking going
# forward from the bounding box to video end and backwards to experiment
# start.
# parameters:
# input video file
# input bounding box and frame number
# experiment start time in ms



inputvideo=$1
userbb=$2
skipfile=$3

echoerr() { echo "$@" 1>&2; }

# vidname=$videodir/$participant"_video.mp4"
# skipname=$outputdir/$participant"_video.skip"
# inbbname=$outputdir/$participant"_videoUser.bbox"
# outbbname=$outputdir/$participant"_video.bbox"
# Detect the first face we can after the start of the experiment
echoerr In BB $userbb
faceinfo=$(cat $userbb)
echoerr $faceinfo
# Extract the frames from t_start to t_face

tstart=$(bc <<< "scale=3;$(cat $skipfile)/1000")
echoerr Experiment starts at $tstart seconds

preexperimentfframes=$(bc <<< "scale=0;$tstart*50")
# Strip decimal
preexperimentframes=${preexperimentfframes%.*}
echoerr Pre-experiment frames $preexperimentframes

faceframe=$(echo $faceinfo | cut -f5 -d,  )
echoerr Frame $faceframe contains frame that bbox was defined at

processframes=$(bc <<< "$faceframe-$preexperimentframes")
echo Going to process $processframes frames

# clean up first in case of failure on previous Run
rm 000*.tga outbbox.csv

# Extract frames; extract all frames from start of the video since -ss
# appears to be unreliable (i.e. set start time)
mplayer  -frames  $faceframe -vo tga  $inputvideo




ls *.tga | sort -r  |head -$processframes > framelist.txt

# OpenCV can read in a sequence of images; should be able to avoid this step
# and hence avoid recompressing the video
mencoder mf://@framelist.txt -mf w=640:h=360:fps=50:type=tga -ovc x264 -x264encopts pass=1:preset=veryslow:fast_pskip=0:tune=film:frameref=15:bitrate=3000:threads=auto -o CppMTvid.avi

echo Running cmt on reversed video
./cmt --bbox=$(echo $faceinfo | cut -f1-4 -d,) --with-rotation --output-file=reversebbox.csv CppMTvid.avi

# Reverse all but the first (header) line, and 1st line
# 1st data line is the given BBOX.  We pick a copy of this on the forward run
# remove first 2 fields and regenerate with correct time and frame number
tail -n +3 reversebbox.csv |tac |  cut -d, -f3- |awk -v OFFSET=`cat $skipfile` -d, '{print (FNR-1)+(OFFSET/20) "," OFFSET + (FNR-1)*20 "," $0 }' > preDetectionbbox.csv

# Run object tracking from given frame and bbox
echo Running cmt on forward video

./cmt --bbox=$(echo $faceinfo | cut -f1-4 -d,) --with-rotation --skip-ms=$(($faceframe*20)) --output-file=postDetectionbbox.csv $inputvideo


head -1 postDetectionbbox.csv > combinedTracking.csv
cat preDetectionbbox.csv >> combinedTracking.csv
tail -n +2 postDetectionbbox.csv >> combinedTracking.csv

# Tidy up
rm 000*.tga  CppMTvid.avi framelist.txt divx2pass.log divx2pass.log.mbtree preDetectionbbox.csv postDetectionbbox.csv
