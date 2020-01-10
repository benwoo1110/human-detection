# import the necessary packages
from singlemotiondetector import SingleMotionDetector
from imutils.video import VideoStream
from flask import Response, Flask, render_template, request
import threading
import argparse
import datetime
import imutils
import time
import cv2
import json
import jsonify

import numpy as np
#from urllib.request import urlopen


#
# initialize a flask object
#
app = Flask(__name__)


#
# Video feed
#
# initialize the output frame and a lock used to ensure thread-safe
# exchanges of the output frames (useful when multiple browsers/tabs
# are viewing the stream)
outputFrame = None
lock = threading.Lock()

data_all = {"time":[], "duration":[], "num_today":[]}

host = 'http://192.168.1.74:8080/'
url = host + 'shot.jpg'

# initialize the video stream and allow the camera sensor to warmup
vs = cv2.VideoCapture(0)
#vs = VideoStream(usePiCamera=1).start()
time.sleep(2.0)

def detect_motion(frameCount):
	# grab global references to the video stream, output frame, and
	# lock variables
    global  vs, outputFrame, lock, data_all

	# initialize the motion detector and the total number of frames
	# read thus far
    md = SingleMotionDetector(accumWeight=0.25)

    curr_data = {"time":"", "duration":"", "num_today":""}
    total = 0
    counter = 0
    time_in_motion = 0
    time_in_toliet = 0
    movement = []
    in_toliet = "Unoccupied"
    # loop over frames from the video stream
    while True:
	# read the next frame from the video stream, resize it,
	# convert the frame to grayscale, and blur it
        ret, frame = vs.read()

        #imgResp=urlopen(url)
        #imgNp=np.array(bytearray(imgResp.read()),dtype=np.uint8)
        #frame=cv2.imdecode(imgNp,-1)

        # frame = imutils.resize(frame, width=600)
        frame = imutils.rotate(frame, 180)
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        gray = cv2.GaussianBlur(gray, (7, 7), 0)

	# grab the current timestamp and draw it on the frame
        timestamp = datetime.datetime.now()
        cv2.putText(frame, timestamp.strftime("%A %d %B %Y %I:%M:%S%p"), (10, frame.shape[0] - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.4, (0, 0, 255), 1)

	# show status of toliet
        cv2.putText(frame, in_toliet, (10, frame.shape[0] - 30), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 2)

	# show toliet entry detection area
        #cv2.rectangle(frame, (50, 420), (520, 480), (255, 0, 255), 2)

	# if the total number of frames has reached a sufficient
	# number to construct a reasonable background model, then
	# continue to process the frame
        if total > frameCount:
	    # detect motion in the image
            motion = md.detect(gray)

	    # check to see if motion was found in the frame
            if motion is not None:
                counter = 0
                if len(movement) == 0: time_in_motion = time.time()

		# unpack the tuple of movement frame
		# "motion area" on the output frame
                (thresh, (minX, minY, maxX, maxY)) = motion

		# Only show if movement more than 500 unit^2 to prevent false detections
                if (maxX-minX)*(maxY-minY) > 500:
                    cv2.rectangle(frame, (minX, minY), (maxX, maxY), (0, 0, 255), 2)

		    # Save movement history
                    movement.append(((minX+maxX)//2, (minY+maxY)//2))

            else:
                counter += 1
		# Threshold incase of missed detection
                if counter > 5:
                    if time.time()-time_in_motion > 0.4:
                        if len(movement) != 0 and 50 < movement[-1][0] < 520 and 420 < movement[-1][1] < 480 and in_toliet != "Occupied": 
                            print("entered")
                            in_toliet = "Occupied"
                            time_in_toliet = time.time()
                            curr_data["time"] = timestamp.strftime("%A %d %B %Y %I:%M:%S%p")
                        if len(movement) != 0 and 50 < movement[0][0] < 520 and 420 < movement[0][1] < 480 and in_toliet != "Unoccupied":
                            print("exited")
                            in_toliet = "Unoccupied"
                            curr_data["duration"] = int(time.time() - time_in_toliet)
                            curr_data["num_today"] = "1"

                            data_all["time"].append(str(curr_data["time"]))
                            data_all["duration"].append(str(curr_data["duration"]))
                            data_all["num_today"].append(str(curr_data["num_today"]))
                            print(data_all)
                    counter, movement = 0, []

	# Show movement history
        movement_points = len(movement)
        for points in range(0, movement_points, 3):
            if points > 0:
                cv2.line(frame, movement[points-3], movement[points], (0, 255, 0), 2)

	# update the background model and increment the total number
	# of frames read thus far
        md.update(gray)
        total += 1

	# acquire the lock, set the output frame, and release the
	# lock
        with lock:
            outputFrame = frame.copy()

def generate():
	# grab global references to the output frame and lock variables
	global outputFrame, lock

	# loop over frames from the output stream
	while True:
		# wait until the lock is acquired
		with lock:
			# check if the output frame is available, otherwise skip
			# the iteration of the loop
			if outputFrame is None:
				continue

			# encode the frame in JPEG format
			(flag, encodedImage) = cv2.imencode(".jpg", outputFrame)

			# ensure the frame was successfully encoded
			if not flag:
				continue

		# yield the output frame in the byte format
		yield(b'--frame\r\n' b'Content-Type: image/jpeg\r\n\r\n' + 
			bytearray(encodedImage) + b'\r\n')

@app.route("/video_feed")
def video_feed():
	# return the response generated along with the specific media
	# type (mime type)
	return Response(generate(),
		mimetype = "multipart/x-mixed-replace; boundary=frame")


#
# Testing request sending
#
@app.route('/data', methods = ['POST', 'GET'])
def data():
    global data_all

    if request.method == 'POST':
        data = request.get_json()

        print (data)
        return "connected"

    if request.method == 'GET':
        return data_all


#
# check to see if this is the main thread of execution
#
if __name__ == '__main__':
	# start a thread that will perform motion detection
	t = threading.Thread(target=detect_motion, args=(
		32,))
	t.daemon = True
	t.start()

	# start the flask app
	app.run(host="192.168.1.249", port=5000, debug=True, threaded=True, use_reloader=False)


#
# Progam ended
#
# release the video stream pointer
#vs.stop()
