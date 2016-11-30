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

cv2.namedWindow(WINDOW_NAME)

frame = 0

if(len(sys.argv)==3):
    skiptime = int(sys.argv[2])
else:
    skiptime = 0

skipframe = skiptime / 20 # TODO - don't hard code
got, img = video.read()
while got:
    frame = frame + 1
    got, img = video.read()
    if(frame > skipframe):
        break


got, img = video.read()
ox = 0
oy = 0
ow, oh, _ = img.shape
#print ox, oy, ow, oh

frame = frame - 1 # Since we advance at the start of the loop below

while got:
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    gray_sm = gray[oy:oh, ox:ow]
    #print gray_sm.shape
    frame = frame + 1


    faces = face_cascade.detectMultiScale(gray_sm, 1.3, 5)
    for (x, y, w, h) in faces:
        print(str(x) + "," + str(y) + "," + str(w) + "," + str(h) + "," + str(frame))
        if(len(faces) > 1):
            print >> sys.stderr, (len(faces))
            print >> sys.stderr, ("WARNING, >1 face detected")
        quit()

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break


    got, img = video.read()

video.release()
cv2.destroyAllWindows()
