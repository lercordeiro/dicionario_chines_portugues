TEX = xelatex
PRE = $(TEX) 
BIB = bibtex
PDFJAM = pdfjam --landscape --signature 20 --twoside --a4paper --suffix livreto

.PHONY: all

all : dicionario.pdf dicionario-livreto.pdf


dicionario.pdf : dicionario.tex verbetes/A.tex verbetes/B.tex verbetes/C.tex verbetes/D.tex verbetes/E.tex verbetes/F.tex verbetes/G.tex verbetes/H.tex verbetes/I.tex verbetes/J.tex verbetes/K.tex verbetes/L.tex verbetes/M.tex verbetes/N.tex verbetes/O.tex verbetes/P.tex verbetes/Q.tex verbetes/R.tex verbetes/S.tex verbetes/T.tex verbetes/U.tex verbetes/V.tex verbetes/W.tex verbetes/X.tex verbetes/Y.tex verbetes/Z.tex 
	$(TEX) dicionario.tex
	$(TEX) dicionario.tex
	$(TEX) dicionario.tex

dicionario-livreto.pdf : dicionario.pdf
	$(PDFJAM) dicionario.pdf

