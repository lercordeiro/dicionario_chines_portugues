TEX = xelatex -halt-on-error -papersize=A4 -8bit #-interaction=batchmode
BIB = bibtex
DSTSITE = /var/www/ler.cordeiro.nom.br/dicionario
DSTREPO = /var/www/repo.ler.cordeiro.nom.br/Dicionário
GENGRP = ./bin/gengroups.py
GRPDIR = ./grupos
INCDIR = ./include
VERBDIR = ./verbetes
VERBTAR = ~/Documentos/Chinês/DCP/verbetes.tar.gz
MKIDX = ~/.local/bin/zhmakeindex -s ./config/main.ist 
BOOK = pdfbook2 --no-crop --signature=20 --paper=a4paper
TIMESTAMP = $(shell date "+%FT%T%z")

all: dicionario.pdf dicionario-livreto.pdf

$(VERBTAR) : 
	echo Already done...

verbetes.tar.gz : $(VERBTAR)
	cp verbetes.tar.gz backup/verbetes.tar.gz.$(TIMESTAMP)
	cp main.pdf backup/main.pdf.$(TIMESTAMP)
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
	$(MKIDX) -z pinyin pinyin
	$(MKIDX) -z bihua stroke
	$(MKIDX) -z bushou radical
	$(TEX) main.tex
	$(TEX) main.tex
	echo -n "Verbetes: "
	grep begin $(VERBDIR)/* | grep verbete | wc -l

main-book.pdf : main.pdf
	$(BOOK) main.pdf

main-livreto.pdf : main-book.pdf
	cp main-book.pdf main-livreto.pdf

dicionario.pdf: main.pdf
	cp main.pdf dicionario.pdf

dicionario-livreto.pdf: main-livreto.pdf
	cp main-livreto.pdf dicionario-livreto.pdf

deploy : dicionario.pdf dicionario-livreto.pdf
	cp dicionario.pdf         $(DSTSITE)
	cp dicionario.pdf         $(DSTREPO)
	cp dicionario-livreto.pdf $(DSTSITE)
	cp dicionario-livreto.pdf $(DSTREPO)

total :
	@echo -n "***** Verbetes: "
	@grep begin $(VERBDIR)/* | grep verbete | wc -l

clean :
	rm -f grupos.done $(GRPDIR)/*.tex *.aux *.idx *.ilg *.ind *.log *.toc *.out

