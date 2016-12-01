#!/bin/bash
# Get bounding box for the start of an experiment by running
# Opencv face prediction from the start point of the experiment (t_start) until
# the first face is detected at t_face.  Then extract frames from t_start to
# t_face, reverse order and create a reversed video.
# Run object tracking on the reversed video and keep the bounding-box of the
# last frame of this video (which will be the bounding-box we
# require for the experiment proper)

participant=$1
vidname=$participant"_video.mp4"
skipname=$participant"_video.skip"
outbbname=$participant"_videoOCV.bbox"
# Detect the first face we can after the start of the experiment
faceinfo=$(python ./getface.py /mnt/IDInteraction/dual_screen_free_experiment/video/experiment2_individual_streams/high_quality/front/$vidname  $(cat /mnt/IDInteraction/dual_screen_free_experiment/tracking/high_quality/front_full_face/$skipname))
echo $faceinfo
# Extract the frames from t_start to t_face

tstart=$(bc <<< "scale=3;$(cat /mnt/IDInteraction/dual_screen_free_experiment/tracking/high_quality/front_full_face/$skipname)/1000")
echo $tstart

faceframe=$(echo $faceinfo | cut -f5 -d,  )
echo $faceframe

processframes=$(printf "%.0f" $(bc <<< "scale=0;$faceframe - ($tstart*50)"))
echo $processframes

# Extract frames
mplayer -ss $tstart -frames  $processframes -vo tga  /mnt/IDInteraction/dual_screen_free_experiment/video/experiment2_individual_streams/high_quality/front/$vidname

ls *.tga | sort -r > framelist.txt

mencoder mf://@framelist.txt -mf w=640:h=360:fps=50:type=tga -ovc x264 -x264encopts pass=1:preset=veryslow:fast_pskip=0:tune=film:frameref=15:bitrate=3000:threads=auto -o CppMTvid.avi

# Run object tracking on reversed video
~/CppMT/cmt CppMTvid.avi --bbox $(echo $faceinfo | cut -f1-4 -d,) --output-file tempbbox.csv

# extract bounding box parameters for last frame of this
tail -1 tempbbox.csv |awk -F, '{OFS=",";print $11,$12,$6,$7}' > $outbbname

echo $faceinfo
echo $tstart
echo $faceframe
echo $processframes
cat $outbbname

# Tidy up
rm 000*.tga tempbbox.csv CppMTvid.avi framelist.txt divx2pass.log divx2pass.log.mbtree
