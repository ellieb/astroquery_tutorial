# Makefile for HTML for Jupyter Notebooks
# For venv stuff
#
OUTDIR=./html
VENVDIR=./temp
py3 = $(shell whereis python | grep -o /usr/bin/python3.? | head -1)
nbs = $(wildcard *.ipynb)
nbs_py3 = $(shell pcregrep -Ml --buffer-size=500K '"language_info": .*(?s) .*"version": 3' $(nbs))
nbs_py2 = $(shell pcregrep -Ml --buffer-size=500K '"language_info": .*(?s) .*"version": 2' $(nbs))

html: $(nbs)
	@echo TARGET FILES: $^
	@echo PYTHON PATH $(py3)
	@echo PY3 NBS $(nbs_py3)
	@echo PY2 NBS $(nbs_py2)

	# TODO: Add script for py3
	# TODO: Pipe OUTDIR to script??`

	$(py3) -m venv $(VENVDIR) ;\
	source $(VENVDIR)/bin/activate ;\

	pip install -U pip ;\
	pip install jupyter jupyter_contrib_nbextensions ;\
	pip install -r requirements3.txt ;\
	jupyter nbconvert --execute --ExecutePreprocessor.timeout=-1 --output-dir=$(OUTDIR) --to html nbs_py3 ;\
	jupyter nbconvert --ExecutePreprocessor.timeout=-1 --output-dir=$(OUTDIR) --to html nbs_py2 ;\
	deactivate ;\
	rm -rf $(VENVDIR) ;\

clean:
	rm -rf ./$(OUTDIR)

help: 
	@echo "make"
	@echo " Convert Jupyter notebooks to html"	
	@echo "make clean"
	@echo "	Remove html directory"

