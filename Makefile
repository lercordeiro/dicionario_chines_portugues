TEX = xelatex
BIB = bibtex
PDFJAM = pdfjam --landscape --signature 20 --twoside --a4paper --suffix livreto
DST = /var/www/ler.cordeiro.nom.br/repositório/Dicionário

verbetes := $(wildcard verbetes/?.tex)

.PHONY: all

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
	$(MV) dicionario.pdf         $(DST)
	$(MV) dicionario-livreto.pdf $(DST)
