#------------------------------------------------------------------------------
# Copyright (c) 2016 The University of Manchester, UK.
#
# Licenced under LGPL version 2.1. See LICENCE for details.
#
# The IDInteraction Processing Pipelines were developed in the IDInteraction
# project, funded by the Engineering and Physical Sciences Research Council,
# UK through grant agreement number EP/M017133/1.
#
# Author: David Mawdsley
#------------------------------------------------------------------------------
#
# IDInteraction OpenCV bounding box detection pipeline
#
# This Makefile uses OpenCV to set the bounding box for each video in a
# fully automatic way.  It uses first face detected after the experiment starts
# and then tracks this backwards until the experiment start itself

getbb=./getbbox.sh
# TODO deal with hardcoded directories
in-dir=/mnt/IDInteraction/dual_screen_free_experiment/video/experiment2_individual_streams/high_quality/front/
#out-dir=output

.PHONY: all bbox
#.PRECIOUS: $(out-dir)/%.skip $(out-dir)/%.bbox $(out-dir)/%.csv

all: bbox


bbox: $(patsubst $(in-dir)/%.mp4,%OCV.bbox,$(wildcard $(in-dir)/*.mp4))

./%OCV.bbox: $(in-dir)/%.mp4
	$(getbb) $(word 1,$(subst _, ,$(notdir $^)))

clean:
	rm -f $(out-dir)/*.skip
	rm -f $(out-dir)/*.bbox
	rm -f $(out-dir)/*.csv
	rm -f $(out-dir)/*_out.avi
