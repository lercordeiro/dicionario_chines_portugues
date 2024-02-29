TEX = xelatex -halt-on-error -papersize=A4 -8bit # -interaction=batchmode
BIB = bibtex
PDFJAM = pdfjam --landscape --signature 20 --twoside --a4paper --suffix livreto
DSTS = /var/www/ler.cordeiro.nom.br/dicionário /var/www/repo.ler.cordeiro.nom.br/Dicionário
GENGRP = ./bin/gengroups.py
GRPDIR = ./grupos
VERBDIR = ./verbetes
MKIDX = ~/.local/bin/zhmakeindex -s dicionario.ist 


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

dicionario-livreto.pdf : dicionario.pdf
	$(PDFJAM) dicionario.pdf

deploy : dicionario.pdf dicionario-livreto.pdf
.for D in $(DSTS)
	cp dicionario.pdf         $(D)
	cp dicionario-livreto.pdf $(D)
.endfor

verbetes :
	echo -n "Verbetes: "
	grep begin $(VERBDIR)/* | grep verbete | wc -l

clean :
	rm -f grupos.done $(GRPDIR)/*.tex *.aux *.idx *.ilg *.ind *.log *.toc *.out

