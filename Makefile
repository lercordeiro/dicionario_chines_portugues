TIMESTAMP != date "+%FT%T%z"

TEX = lualatex -halt-on-error -8bit # -papersize=A4 -interaction=batchmode
BOOK = pdfjam --a4paper --landscape --twoside --signature 20 --suffix booklet --otheredge --

INCDIR = ./include
BKPDIR = ./backup
DSTSITE = /var/www/download/dictionary
DSTREPO = /var/www/repo.ler.cordeiro.nom.br/Dicionário

PGRPDIR = ./groups.by.pinyins
SGRPDIR = ./groups.by.strokes
RGRPDIR = ./groups.by.radicals

PGRPTAR = ~/中文/Entries/groups.by.pinyins.tar.gz
SGRPTAR = ~/中文/Entries/groups.by.strokes.tar.gz
RGRPTAR = ~/中文/Entries/groups.by.radicals.tar.gz

GENINV = $(INCDIR)/cmds.tex \
         $(INCDIR)/classificadores.nominais.tex \
         $(INCDIR)/classificadores.verbais.tex \
         $(INCDIR)/locativos.tex \
         $(INCDIR)/radicais.kangxi.tex \
         $(INCDIR)/termos.gramaticais.tex \
         $(INCDIR)/verbos.direcionais.tex \
         $(INCDIR)/hyphenation.tex \
         $(INCDIR)/tex-sx-pinyin-tonemarks.lua
 

all: dictionary-pinyins dictionary-strokes dicrionary-radicals 

deploy: deploy-pinyins deploy-strokes deploy-radicals


dictuinary_pinyins: dicionario_pinyins.pdf livreto_pinyins.pdf

deploy-pinyins: dicionario_pinyins.pdf livreto_pinyins.pdf
	cp dicionario_pinyins.pdf	$(DSTSITE)
	cp livreto_pinyins.pdf		$(DSTSITE)
	cp dicionario_pinyins.pdf	$(DSTREPO)
	cp livreto_pinyins.pdf		$(DSTREPO)

dicionario_pinyins.pdf: pinyins.pdf
	cp pinyins.pdf dicionario_pinyins.pdf

livreto_pinyins.pdf: pinyins-booklet.pdf
	cp pinyins-booklet.pdf livreto_pinyins.pdf

pinyins-booklet.pdf: pinyins.pdf
	$(BOOK) pinyins.pdf

pinyins.pdf: pinyins.tex extract.groups.by.pinyins.done $(GENINC)
	$(TEX) pinyins.tex
	$(TEX) pinyins.tex
	$(TEX) pinyins.tex
	$(TEX) pinyins.tex
	echo -n "Verbetes: "
	@grep begin $(PGRPDIR)/* | grep Entry | wc -l

extract.groups.by.pinyins.done: groups.by.pinyins.tar.gz
	tar xvzf groups.by.pinyins.tar.gz
	touch extract.groups.by.pinyins.done

groups.by.pinyins.tar.gz: $(PGRPTAR)
	cp $(PGRPTAR) .

$(PGRPTAR):


dictionary-strokes: dicionario_tracos.pdf livreto_tracos.pdf

deploy-strokes: dicionario_tracos.pdf livreto_tracos.pdf
	cp dicionario_tracos.pdf	$(DSTSITE)
	cp livreto_tracos.pdf		$(DSTSITE)
	cp dicionario_tracos.pdf	$(DSTREPO)
	cp livreto_tracos.pdf		$(DSTREPO)

dicionario_tracos.pdf: strokes.pdf
	cp strokes.pdf dicionario_tracos.pdf

livreto_tracos.pdf: strokes-booklet.pdf
	cp strokes-booklet.pdf livreto_tracos.pdf

strokes-booklet.pdf: strokes.pdf
	$(BOOK) strokes.pdf

strokes.pdf: strokes.tex extract.groups.by.strokes.done $(GENINC)
	$(TEX) strokes.tex
	$(TEX) strokes.tex
	$(TEX) strokes.tex
	$(TEX) strokes.tex
	echo -n "Verbetes: "
	@grep begin $(SGRPDIR)/* | grep Entry | wc -l

extract.groups.by.strokes.done: groups.by.strokes.tar.gz
	tar xvzf groups.by.strokes.tar.gz
	touch extract.groups.by.strokes.done

groups.by.strokes.tar.gz: $(SGRPTAR)
	cp $(SGRPTAR) .

$(SGRPTAR):


dictionary-radicals: dicionario_radicais.pdf livreto_radicais.pdf

deploy-radicals: dicionario_radicais.pdf livreto_radicais.pdf
	cp dicionario_radicais.pdf	$(DSTSITE)
	cp livreto_radicais.pdf		$(DSTSITE)
	cp dicionario_radicais.pdf	$(DSTREPO)
	cp livreto_radicais.pdf		$(DSTREPO)

dicionario_radicais.pdf: radicals.pdf
	cp radicals.pdf dicionario_radicais.pdf

livreto_radicais.pdf: radicals-booklet.pdf
	cp radicals-booklet.pdf livreto_radicais.pdf

radicals-booklet.pdf: radicals.pdf
	$(BOOK) radicals.pdf

radicals.pdf: radicals.tex extract.groups.by.radicals.done $(GENINC)
	$(TEX) radicals.tex
	$(TEX) radicals.tex
	$(TEX) radicals.tex
	$(TEX) radicals.tex
	echo -n "Verbetes: "
	@grep begin $(RGRPDIR)/* | grep Entry | wc -l

extract.groups.by.radicals.done: groups.by.radicals.tar.gz
	tar xvzf groups.by.radicals.tar.gz
	touch extract.groups.by.radicals.done

groups.by.radicals.tar.gz: $(RGRPTAR)
	cp $(RGRPTAR) .

$(RGRPTAR):


total:
	@echo -n "***** Verbetes Pinyin..: "
	@grep begin $(PGRPDIR)/* | grep Entry | wc -l
	@echo -n "***** Verbetes Tracos..: "
	@grep begin $(SGRPDIR)/* | grep Entry | wc -l
	@echo -n "***** Verbetes Radicais: "
	@grep begin $(RGRPDIR)/* | grep Entry | wc -l


clean :
	rm -f $(PGRPDIR)/*
	rm -f $(SGRPDIR)/*
	rm -f $(RGRPDIR)/*
	rm -f *.aux *.idx *.ilg *.ind *.log *.toc *.out *.done 

