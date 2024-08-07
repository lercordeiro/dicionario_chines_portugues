TEX = lualatex -halt-on-error -8bit # -papersize=A4 -interaction=batchmode
BIB = bibtex
DSTSITE = /var/www/ler.cordeiro.nom.br/dicionario
DSTREPO = /var/www/repo.ler.cordeiro.nom.br/Dicionário
GENGRP = ./bin/gengroups.py
GRPDIR = ./grupos
INCDIR = ./include
VERBDIR = ./verbetes
VERBTAR = ~/Documentos/Chinês/DCP/verbetes.tar.gz
MKIDX = ~/.local/bin/zhmakeindex -s ./config/main.ist 
BOOK = pdfjam --landscape --signature 20 --twoside --a4paper --suffix livreto 
TIMESTAMP != date "+%FT%T%z"

all: dicionario.pdf dicionario-livreto.pdf

$(VERBTAR) : 
	echo Already done...

verbetes.tar.gz : $(VERBTAR)
	cp verbetes.tar.gz backup/verbetes.tar.gz.${TIMESTAMP}
	cp main.pdf backup/main.pdf.${TIMESTAMP}
	cp $(VERBTAR) .
	rm -f verbetes/* grupos/*

verbetes : verbetes.tar.gz
	
$(VERBDIR)/%.tex : verbetes.tar.gz
	tar xvzf verbetes.tar.gz

$(GRPDIR)/%.tex : $(VERBDIR)/%.tex
	$(GENGRP) -r $(VERBDIR) -w $(GRPDIR)

$(INCDIR)/%.tex :
	echo Already done...
 
main : main.pdf

main.pdf : main.tex $(INCDIR)/%.tex $(GRPDIR)/%.tex
	$(TEX) main.tex
	$(MKIDX) -z bihua stroke
	$(MKIDX) -z bushou radical
	$(TEX) main.tex
	$(TEX) main.tex
	echo -n "Verbetes: "
	grep begin $(VERBDIR)/* | grep verbete | wc -l

main-livreto.pdf : main.pdf
	$(BOOK) main.pdf

dicionario.pdf: main.pdf
	cp main.pdf dicionario.pdf

dicionario-livreto.pdf: main-livreto.pdf
	cp main-livreto.pdf dicionario-livreto.pdf

deploy : dicionario.pdf dicionario-livreto.pdf
	cp dicionario.pdf         $(DSTSITE)
	cp dicionario.pdf         $(DSTREPO)
	cp dicionario-livreto.pdf $(DSTSITE)
	cp dicionario-livreto.pdf $(DSTREPO)
	/usr/home/lercordeiro/.local/bin/dicionario-status

total :
	@echo -n "***** Verbetes: "
	@grep begin $(VERBDIR)/* | grep verbete | wc -l

clean :
	rm -f grupos.done $(GRPDIR)/*.tex *.aux *.idx *.ilg *.ind *.log *.toc *.out

