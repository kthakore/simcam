all: seminar.pdf 

show: all 
	evince seminar.pdf 

figs:
	mpost figs/*.mp

seminar.pdf:
	rubber -d seminar.tex 

clean:
	git clean -xf
