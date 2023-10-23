TEX = xelatex -halt-on-error -papersize=A4 -8bit 
BIB = bibtex
PDFJAM = pdfjam --landscape --signature 20 --twoside --a4paper --suffix livreto
DST = /var/www/ler.cordeiro.nom.br/repositório/Dicionário

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
	cp dicionario.pdf         $(DST)
	cp dicionario-livreto.pdf $(DST)

clean:
	rm dicionario.aux
	rm dicionario.idx
	rm dicionario.ilg
	rm dicionario.ind
	rm dicionario.log
	rm dicionario.toc
	rm dicionario.pdf

