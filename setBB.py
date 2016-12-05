#!/usr/bin/python
#! Load in a video and let us go through it frame-by-frame.
#! Select a bounding box and output when we're on the appropriate frame

import cv2
import os
import csv
import sys

WINDOW_NAME = "BoundingBoxSelection"


def getbbox(event, x, y, flags, param):
    global refpt

    if event == cv2.cv.CV_EVENT_LBUTTONDOWN:
        refpt = [(x,y)]
        cv2.putText(img,str(refpt), (200,200), cv2.cv.CV_FONT_HERSHEY_SIMPLEX, 1, 255, 2)
    elif  event == cv2.cv.CV_EVENT_LBUTTONUP:
        refpt.append((x,y))
        cv2.rectangle(img, refpt[0], refpt[1], (0, 255, 0), 2)
        cv2.imshow(WINDOW_NAME, img)


video = cv2.VideoCapture(sys.argv[1])
cv2.namedWindow(WINDOW_NAME)
cv2.setMouseCallback(WINDOW_NAME, getbbox)
refpt = []

if(len(sys.argv) > 2):
    print >> sys.stderr, ("Skipping " + sys.argv[2] + " ms")
    video.set(cv2.cv.CV_CAP_PROP_POS_MSEC, int(sys.argv[2]))

got, img = video.read()

while got:
    frame = video.get(cv2.cv.CV_CAP_PROP_POS_FRAMES)
    cv2.putText(img,str(int(frame)), (50,50), cv2.cv.CV_FONT_HERSHEY_SIMPLEX, 1, 255, 2)

    cv2.imshow(WINDOW_NAME, img)

    if len(refpt) == 2:
        x = refpt[0][0]
        y = refpt[0][1]
        w = refpt[1][0] - x
        h = refpt[1][1] - y

        if w < 0 or h < 0:
            print("Bounding box must be dragged from top left to bottom right")
            quit()
        print(str(x) + "," + str(y) + "," + str(w) + "," + str(h) + "," + str(int(frame)))
        quit()

    key = cv2.waitKey(0) & 0xFF

    if key == ord("q"):
        break
    elif key == ord("b"):
        # Back up a frame (-2 since we're going to advance by 1 at
        # the end of the loop)
        video.set(cv2.cv.CV_CAP_PROP_POS_FRAMES, frame - 2)

    got, img = video.read()
