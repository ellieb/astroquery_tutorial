# Makefile for HTML for Jupyter Notebooks

OUTDIR=html

nbs = $(wildcard *.ipynb)
nbs_py3 = $(shell pcregrep -Ml --buffer-size=500K '"language_info": .*(?s).*"version": 3' $(nbs))
nbs_py2 = $(shell pcregrep -Ml --buffer-size=500K '"language_info": .*(?s).*"version": 2' $(nbs))
py3 = $(shell whereis python | grep -o /usr/bin/python3.? | head -1)

html: $(nbs)
	@echo TARGET FILES: $^
	$(eval VENVDIR := $(shell mktemp -d venvtemp.XXX))

	$(py3) -m venv ./$(VENVDIR) ;\
	source ./$(VENVDIR)/bin/activate ;\

	@echo Installing requirements
	pip install -U pip ;\
	pip install jupyter jupyter_contrib_nbextensions ;\
	pip install -r requirements3.txt ;\

	@echo Converting notebooks to HTML
	jupyter nbconvert --execute --ExecutePreprocessor.timeout=-1 --output-dir=./$(OUTDIR) --to html $(nbs_py3) ;\
	jupyter nbconvert --ExecutePreprocessor.timeout=-1 --output-dir=./$(OUTDIR) --to html $(nbs_py2) ;\

	@echo Shutting down virtural env and removing temp dir
	deactivate ;\
	rm -rf ./$(VENVDIR) ;\

clean:
	rm -rf $(OUTDIR)

help: 
	@echo "make"
	@echo " Convert Jupyter notebooks to html"
	@echo "make clean"
	@echo " Remove html directory"

