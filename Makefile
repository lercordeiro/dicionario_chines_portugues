TEX = xelatex -halt-on-error -papersize=A4 -8bit #-interaction=batchmode
BIB = bibtex
DST_SITE = /var/www/ler.cordeiro.nom.br/dicionario
DST_REPO = /var/www/repo.ler.cordeiro.nom.br/Dicionário
GENGRP = ./bin/gengroups.py
GRPDIR = ./grupos
ALLDIR = ./todos_os_verbetes
INCDIR = ./include
VERBDIR = ./verbetes
MKIDX = ~/.local/bin/zhmakeindex -s ./config/main.ist 
BOOK = pdfbook2 --no-crop --signature=20 --paper=a4paper

all: dicionario.pdf dicionario-livreto.pdf

arquivo :
	tar cvzf verbetes.tar.gz $(VERBDIR)
	rm -f grupos.done

grupos.done : verbetes.tar.gz
	tar xvzf verbetes.tar.gz
	$(GENGRP) -r $(VERBDIR) -w $(GRPDIR) -a $(ALLDIR)
	touch grupos.done

grupos : grupos.done

main : main.pdf 

main.pdf : main.tex $(INCDIR)/*.tex grupos.done
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

dicionario-livreto.pdf: main.pdf
	cp main.pdf dicionario-livreto.pdf

deploy : dicionario.pdf dicionario-livreto.pdf
	cp dicionario.pdf         $(DST_SITE)
	cp dicionario.pdf         $(DST_REPO)
	cp dicionario-livreto.pdf $(DST_SITE)
	cp dicionario-livreto.pdf $(DST_REPO)

verbetes :
	@echo -n "***** Verbetes: "
	@grep begin $(VERBDIR)/* | grep verbete | wc -l

clean :
	rm -f grupos.done $(GRPDIR)/*.tex *.aux *.idx *.ilg *.ind *.log *.toc *.out

