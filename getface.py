#!/usr/bin/python
# Return the bounding box of the first face detected after
# a specified number of MS
# (This is used to "seed" the CppMT process with a face)
import cv2
import os
import csv
import sys


WINDOW_NAME = 'Detection'


face_cascade = cv2.CascadeClassifier('/usr/share/opencv/haarcascades/haarcascade_frontalface_alt2.xml')

eye_cascade = cv2.CascadeClassifier('/usr/share/opencv/haarcascades/haarcascade_mcs_eyepair_small.xml')

video = cv2.VideoCapture(sys.argv[1])

#cv2.namedWindow(WINDOW_NAME)

if(len(sys.argv) > 2):
    print >> sys.stderr, ("Skipping " + sys.argv[2] + " ms")
    video.set(cv2.cv.CV_CAP_PROP_POS_MSEC, int(sys.argv[2]))

got, img = video.read()
ox = 0
oy = 0
ow, oh, _ = img.shape
#print ox, oy, ow, oh



while got:
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    gray_sm = gray[oy:oh, ox:ow]
    #print gray_sm.shape
    frame = video.get(cv2.cv.CV_CAP_PROP_POS_FRAMES)


    faces = face_cascade.detectMultiScale(gray_sm, 1.3, 5)
    for (x, y, w, h) in faces:
        print(str(x) + "," + str(y) + "," + str(w) + "," + str(h) + "," + str(int(frame)))
        if(len(faces) > 1):
            print >> sys.stderr, (len(faces))
            print >> sys.stderr, ("WARNING, >1 face detected")
        quit()

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break


    got, img = video.read()

video.release()
cv2.destroyAllWindows()
