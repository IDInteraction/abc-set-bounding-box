#!/bin/bash
# Get bounding box for the start of an experiment by running backwards
# from a prespecified bounding box and frame (x,y,width,height,frame)
# to the start of the experiment.

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

# Run object tracking on reversed video
./cmt CppMTvid.avi --bbox $(echo $faceinfo | cut -f1-4 -d,) --output-file tempbbox.csv

# extract bounding box parameters for last frame of reversed video
# which will be the bounding box at the experiment start frame

tail -1 tempbbox.csv |awk -F, '{OFS=",";print $11,$12,$6,$7}' > outbbox.csv

# Tidy up
rm 000*.tga  CppMTvid.avi framelist.txt divx2pass.log divx2pass.log.mbtree # tempbbox.csv
