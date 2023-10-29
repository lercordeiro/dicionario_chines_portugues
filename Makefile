TEX = xelatex -halt-on-error -papersize=A4 -8bit 
BIB = bibtex
PDFJAM = pdfjam --landscape --signature 20 --twoside --a4paper --suffix livreto
DSTS = /var/www/ler.cordeiro.nom.br/dicionário /var/www/ler.cordeiro.nom.br/Repositório/Dicionário

verbetes := $(wildcard verbetes/*.tex)

.PHONY: dicionario.pdf dicionario-livreto.pdf

all : dicionario.pdf dicionario-livreto.pdf

one : dicionario.tex $(verbetes)
	$(TEX) dicionario.tex

dicionario.pdf : dicionario.tex $(verbetes)
	$(TEX) dicionario.tex
	$(TEX) dicionario.tex
	$(TEX) dicionario.tex

dicionario-livreto.pdf : dicionario.pdf
	$(PDFJAM) dicionario.pdf

deploy : dicionario.pdf dicionario-livreto.pdf
.for D in $(DSTS)
	cp dicionario.pdf         $(D)
	cp dicionario-livreto.pdf $(D)
.endfor

clean:
	rm dicionario.aux
	rm dicionario.idx
	rm dicionario.ilg
	rm dicionario.ind
	rm dicionario.log
	rm dicionario.toc
	rm dicionario.pdf

