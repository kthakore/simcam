all: acm.pdf 

show: all 
	evince acm.pdf 

figs:
	mpost figs/*.mp

acm.pdf:
	rubber -d acm.tex 

clean:
	git clean -xf
