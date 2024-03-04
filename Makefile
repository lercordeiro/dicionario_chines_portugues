TEX = xelatex -halt-on-error -papersize=A4 -8bit # -interaction=batchmode
BIB = bibtex
DST_SITE = /var/www/ler.cordeiro.nom.br/dicionário
DST_REPO = /var/www/repo.ler.cordeiro.nom.br/Dicionário
GENGRP = ./bin/gengroups.py
GRPDIR = ./grupos
VERBDIR = ./verbetes
MKIDX = ~/.local/bin/zhmakeindex -s dicionario.ist 
BOOK = pdfbook2 --no-crop --signature=20 --paper=a4paper


all: dicionario.pdf dicionario-livreto.pdf

arquivo :
	tar cvzf verbetes.tar.gz $(VERBDIR)
	rm -f grupos.done

grupos.done : verbetes.tar.gz
	tar xvzf verbetes.tar.gz
	$(GENGRP) -r $(VERBDIR) -w $(GRPDIR)
	touch grupos.done

grupos : grupos.done

dicionario : dicionario.pdf 

dicionario.pdf : dicionario.tex comandos.tex termos.tex radicais.tex grupos.done
	$(TEX) dicionario.tex
	$(MKIDX) -z pinyin pinyin
	$(MKIDX) -z bihua stroke
	$(MKIDX) -z bushou radical
	$(TEX) dicionario.tex
	$(TEX) dicionario.tex
	echo -n "Verbetes: "
	grep begin $(VERBDIR)/* | grep verbete | wc -l

dicionario-book.pdf : dicionario.pdf
	$(BOOK) dicionario.pdf

dicionario-livreto.pdf : dicionario-book.pdf
	cp dicionario-book.pdf dicionario-livreto.pdf

deploy : dicionario.pdf dicionario-livreto.pdf
	cp dicionario.pdf         $(DST_SITE)
	cp dicionario.pdf         $(DST_REPO)
	cp dicionario-livreto.pdf $(DST_SITE)
	cp dicionario-livreto.pdf $(DST_REPO)

verbetes :
	echo -n "Verbetes: "
	grep begin $(VERBDIR)/* | grep verbete | wc -l

clean :
	rm -f grupos.done $(GRPDIR)/*.tex *.aux *.idx *.ilg *.ind *.log *.toc *.out

