TIMESTAMP != date "+%FT%T%z"

TEX = lualatex -halt-on-error -8bit # -papersize=A4 -interaction=batchmode
BOOK = pdfjam --a4paper --landscape --twoside --signature 20 --suffix booklet --otheredge --

INCDIR = ./include
BKPDIR = ./backup
DSTSITE = /var/www/download/dictionary
DSTREPO = /var/www/repo.ler.cordeiro.nom.br/Dicionário

PGENGRP = ./bin/gengroupsbypinyins.py
PVERBTAR = ~/中文/Entries/entries_by_pinyins.tar.gz
PVERBDIR = ./entries_by_pinyins
PGRPDIR = ./groups_by_pinyins

SGENGRP = ./bin/gengroupsbystrokes.py
SVERBTAR = ~/中文/Entries/entries_by_strokes.tar.gz
SVERBDIR = ./entries_by_strokes
SGRPDIR = ./groups_by_strokes
 
RGENGRP = ./bin/gengroupsbyradicals.py
RVERBTAR = ~/中文/Entries/entries_by_radicals.tar.gz
RVERBDIR = ./entries_by_radicals
RGRPDIR = ./groups_by_radicals

GENINV = $(INCDIR)/cmds.tex \
         $(INCDIR)/classificadores_nominais.tex \
         $(INCDIR)/classificadores_verbais.tex \
         $(INCDIR)/locativos.tex \
         $(INCDIR)/radicais_kangxi.tex \
         $(INCDIR)/termos_gramaticais.tex \
         $(INCDIR)/verbos_direcionais.tex \
         $(INCDIR)/hyphenation.tex \
         $(INCDIR)/tex-sx-pinyin-tonemarks.lua
 
all : dicionario_pinyins dicionario_tracos dicionario_radicais dicionario_combinado

dicionario_pinyins : dicionario_pinyins.pdf livreto_pinyins.pdf

dicionario_tracos : dicionario_tracos.pdf livreto_tracos.pdf

dicionario_radicais : dicionario_radicais.pdf livreto_radicais.pdf

dicionario_combinado : dicionario_combinado.pdf livreto_combinado.pdf

$(PVERBTAR) :
	ls -l $(PVERBTAR)

$(SVERBTAR) :
	ls -l $(SVERBTAR)

$(RVERBTAR) :
	ls -l $(RVERBTAR)

entries_by_pinyins.tar.gz : $(PVERBTAR)
	cp $(PVERBTAR) .
	rm -f ${PVERBDIR}/* ${PGRPDIR}/*

entries_by_strokes.tar.gz : $(SVERBTAR)
	cp $(SVERBTAR) .
	rm -f ${SVERBDIR}/* ${SGRPDIR}/*

entries_by_radicals.tar.gz : $(RVERBTAR)
	cp $(RVERBTAR) .
	rm -f ${RVERBDIR}/* ${RGRPDIR}/*

entries_by_pinyins.tar.gz.done : entries_by_pinyins.tar.gz
	touch entries_by_pinyins.tar.gz.done

entries_by_radicals.tar.gz.done : entries_by_radicals.tar.gz
	touch entries_by_radicals.tar.gz.done

entries_by_strokes.tar.gz.done : entries_by_strokes.tar.gz
	touch entries_by_strokes.tar.gz.done

extract.entries_by_pinyins.tar.gz : entries_by_pinyins.tar.gz.done
	tar xvzf entries_by_pinyins.tar.gz

extract.entries_by_strokes.tar.gz : entries_by_strokes.tar.gz.done
	tar xvzf entries_by_strokes.tar.gz

extract.entries_by_radicals.tar.gz : entries_by_radicals.tar.gz.done
	tar xvzf entries_by_radicals.tar.gz

extract.entries_by_pinyins.tar.gz.done : extract.entries_by_pinyins.tar.gz
	touch extract.entries_by_pinyins.tar.gz.done

extract.entries_by_strokes.tar.gz.done : extract.entries_by_strokes.tar.gz
	touch extract.entries_by_strokes.tar.gz.done

extract.entries_by_radicals.tar.gz.done : extract.entries_by_radicals.tar.gz
	touch extract.entries_by_radicals.tar.gz.done

group.by.pinyins : extract.entries_by_pinyins.tar.gz.done
	$(PGENGRP) -r $(PVERBDIR) -w $(PGRPDIR)

group.by.strokes : extract.entries_by_strokes.tar.gz.done
	$(SGENGRP) -r $(SVERBDIR) -w $(SGRPDIR)

group.by.radicals : extract.entries_by_radicals.tar.gz.done
	$(RGENGRP) -r $(RVERBDIR) -w $(RGRPDIR)

group.by.pinyins.done : group.by.pinyins
	touch group.by.pinyins.done

group.by.strokes.done : group.by.strokes
	touch group.by.strokes.done

group.by.radicals.done : group.by.radicals
	touch group.by.radicals.done

pinyins.pdf : pinyins.tex group.by.pinyins.done $(GENINC)
	$(TEX) pinyins.tex
	$(TEX) pinyins.tex
	$(TEX) pinyins.tex
	$(TEX) pinyins.tex
	echo -n "Verbetes: "
	@grep begin $(PGRPDIR)/* | grep Entry | wc -l

strokes.pdf : strokes.tex group.by.strokes.done $(GENINC)
	$(TEX) strokes.tex
	$(TEX) strokes.tex
	$(TEX) strokes.tex
	$(TEX) strokes.tex
	echo -n "Verbetes: "
	@grep begin $(SGRPDIR)/* | grep Entry | wc -l

radicals.pdf : radicals.tex group.by.radicals.done $(GENINC) 
	$(TEX) radicals.tex
	$(TEX) radicals.tex
	$(TEX) radicals.tex
	$(TEX) radicals.tex
	echo -n "Verbetes: "
	@grep begin $(RGRPDIR)/* | grep Entry | wc -l

full.pdf : full.tex group.by.pinyins.done group.by.strokes.done group.by.radicals.done $(GENINC)
	$(TEX) full.tex
	$(TEX) full.tex
	$(TEX) full.tex

pinyins-booklet.pdf : pinyins.pdf
	$(BOOK) pinyins.pdf

strokes-booklet.pdf : strokes.pdf
	$(BOOK) strokes.pdf

radicals-booklet.pdf : radicals.pdf
	$(BOOK) radicals.pdf

full-booklet.pdf : full.pdf
	$(BOOK) full.pdf

dicionario_pinyins.pdf : pinyins.pdf
	cp pinyins.pdf dicionario_pinyins.pdf

dicionario_tracos.pdf : strokes.pdf
	cp strokes.pdf dicionario_tracos.pdf

dicionario_radicais.pdf : radicals.pdf
	cp radicals.pdf dicionario_radicais.pdf

dicionario_combinado.pdf : full.pdf
	cp full.pdf dicionario_combinado.pdf

livreto_pinyins.pdf : pinyins-booklet.pdf
	cp pinyins-booklet.pdf livreto_pinyins.pdf

livreto_tracos.pdf : strokes-booklet.pdf
	cp strokes-booklet.pdf livreto_tracos.pdf

livreto_radicais.pdf : radicals-booklet.pdf
	cp radicals-booklet.pdf livreto_radicais.pdf

livreto_combinado.pdf : full-booklet.pdf
	cp full-booklet.pdf livreto_combinado.pdf

deploy-pinyins : dicionario_pinyins.pdf livreto_pinyins.pdf
	cp dicionario_pinyins.pdf	$(DSTSITE)
	cp livreto_pinyins.pdf		$(DSTSITE)
	cp dicionario_pinyins.pdf	$(DSTREPO)
	cp livreto_pinyins.pdf		$(DSTREPO)

deploy-strokes : dicionario_tracos.pdf livreto_tracos.pdf
	cp dicionario_tracos.pdf	$(DSTSITE)
	cp livreto_tracos.pdf		$(DSTSITE)
	cp dicionario_tracos.pdf	$(DSTREPO)
	cp livreto_tracos.pdf		$(DSTREPO)

deploy-radicals : dicionario_radicais.pdf livreto_radicais.pdf
	cp dicionario_radicais.pdf	$(DSTSITE)
	cp livreto_radicais.pdf		$(DSTSITE)
	cp dicionario_radicais.pdf	$(DSTREPO)
	cp livreto_radicais.pdf		$(DSTREPO)

deploy-full : dicionario_combinado.pdf livreto_combinado.pdf
	cp dicionario_combinado.pdf	$(DSTSITE)
	cp livreto_combinado.pdf	$(DSTSITE)
	cp dicionario_combinado.pdf	$(DSTREPO)
	cp livreto_combinado.pdf	$(DSTREPO)

deploy : deploy-pinyins deploy-strokes deploy-radicals deploy-full

total:
	@echo -n "***** Verbetes Pinyin..: "
	@grep begin $(PGRPDIR)/* | grep Entry | wc -l
	@echo -n "***** Verbetes Tracos..: "
	@grep begin $(SGRPDIR)/* | grep Entry | wc -l
	@echo -n "***** Verbetes Radicais: "
	@grep begin $(RGRPDIR)/* | grep Entry | wc -l


clean :
	find $(PVERBDIR) -name "*.tex" -type f -delete
	find $(SVERBDIR) -name "*.tex" -type f -delete
	find $(RVERBDIR) -name "*.tex" -type f -delete
	rm -f *.aux *.idx *.ilg *.ind *.log *.toc *.out *.done 

