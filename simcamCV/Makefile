CC = gcc -x c++
CFLAGS = -lopencv_imgproc -lopencv_highgui -lopencv_calib3d -lopencv_core

all: check calibrate noise distort diff

check:
	$(CC) -o check check.c $(CFLAGS)

calibrate:
	$(CC) -o calibrate calibrate.c $(CFLAGS)

noise:
	$(CC) -o noise noise.cpp $(CFLAGS)

distort:
	$(CC) -o distort distort.c $(CFLAGS)

diff:
	$(CC) -o diff diff.c $(CFLAGS)

