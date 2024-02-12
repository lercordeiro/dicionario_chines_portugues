TEX = xelatex -halt-on-error -papersize=A4 -8bit # -interaction=batchmode
BIB = bibtex
PDFJAM = pdfjam --landscape --signature 20 --twoside --a4paper --suffix livreto
DSTS = /var/www/ler.cordeiro.nom.br/dicionário /var/www/repo.ler.cordeiro.nom.br/Dicionário
GENGRP = ./bin/gengroups.py
GRPDIR = ./grupos
VERBDIR = ./verbetes
MKIDX = ~/.local/bin/zhmakeindex -s dicionario.ist 


$(VERBDIR)/%.tex: verbetes.tar.gz
	tar xvzf verbetes.tar.gz

$(GRPDIR)/%.tex: $(VERBDIR)/%.tex
	$(GENGRP) -r verbetes -w grupos

archive:
	tar cvzf verbetes.tar.gz ./verbetes

grupos: $(VERBDIR)/%.tex
	$(GENGRP) -r verbetes -w grupos

dicionario: dicionario.pdf

dicionario.pdf : dicionario.tex $(GRPDIR)/%.tex
	$(TEX) dicionario.tex
	$(MKIDX) -z pinyin pinyin
	$(MKIDX) -z bihua stroke
	$(MKIDX) -z bushou radical
	$(TEX) dicionario.tex
	$(TEX) dicionario.tex

dicionario-livreto.pdf : dicionario.pdf
	$(PDFJAM) dicionario.pdf

deploy : dicionario.pdf dicionario-livreto.pdf
.for D in $(DSTS)
	cp dicionario.pdf         $(D)
	cp dicionario-livreto.pdf $(D)
.endfor

all : dicionario.pdf dicionario-livreto.pdf

clean:
	rm $(GRPDIR)/*.tex
	rm *.aux
	rm *.idx
	rm *.ilg
	rm *.ind
	rm *.log
	rm *.toc
	rm *.out

