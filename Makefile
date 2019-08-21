# Makefile for HTML for Jupyter Notebooks

OUTDIR=html
NBFILES = $(wildcard *.ipynb)
HTMLFILES = $(patsubst %.ipynb,%.html,$(NBFILES))
NBPY3 = $(shell pcregrep -Ml --buffer-size=500K '"language_info": .*(?s).*"version": 3' $(NBFILES))
NBPY2 = $(shell pcregrep -Ml --buffer-size=500K '"language_info": .*(?s).*"version": 2' $(NBFILES))
PY3 = $(shell whereis python | grep -o /usr/bin/python3.? | head -1)

NBCONVERT = jupyter nbconvert --output-dir=./$(OUTDIR) --to html

html:
	@echo NOTEBOOK FILES: $(NBFILES)
	@echo TARGET: $^

	$(eval VENVDIR := $(shell mktemp -d venvtemp.XXX))

ifdef NBPY3
	$(PY3) -m venv ./$(VENVDIR) ;\
	source ./$(VENVDIR)/bin/activate ;\

	@echo Installing requirements
	pip install -U pip ;\
	pip install jupyter jupyter_contrib_nbextensions ;\
	pip install -r requirements3.txt ;\

	@echo Converting notebooks to HTML
	$(NBCONVERT) $(NBPY3) --ExecutePreprocessor.timeout=-1 --execute

	@echo Shutting down virtural env and removing temp dir
	deactivate ;\
	rm -rf ./$(VENVDIR) ;\

endif

ifdef NBPY2
	$(NBCONVERT) $(NBPY2) ;\

endif 


clean:
	rm -rf $(OUTDIR) ;\

help: 
	@echo "make"
	@echo " Convert Jupyter notebooks to html"
	@echo "make clean"
	@echo " Remove html directory"

