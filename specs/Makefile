all:
	rm software_specs.pdf; rubber -d software_specs.tex; makeglossaries software_specs; rm software_specs.pdf; rubber -d software_specs.tex;

show: all 
	evince software_specs.pdf 
