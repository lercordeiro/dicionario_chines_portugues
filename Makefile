TIMESTAMP != date "+%FT%T%z"

TEX = lualatex -halt-on-error -8bit # -papersize=A4 -interaction=batchmode
BOOK = pdfjam --landscape --signature 20 --twoside --a4paper --suffix booklet

INCDIR = ./include
BKPDIR = ./backup
DSTSITE = /var/www/ler.cordeiro.nom.br/dicionario
DSTREPO = /var/www/repo.ler.cordeiro.nom.br/Dicionário

PGENGRP = ./bin/gengroupsbypinyin.py
PVERBTAR = ~/Documentos/Chinês/DCP/entries_by_pinyin.tar.gz
PVERBDIR = ./entries_by_pinyin
PGRPDIR = ./groups_by_pinyin

SGENGRP = ./bin/gengroupsbystrokes.py
SVERBTAR = ~/Documentos/Chinês/DCP/entries_by_strokes.tar.gz
SVERBDIR = ./entries_by_strokes
SGRPDIR = ./groups_by_strokes
 
all : dicionario_por_pinyin dicionario_por_tracos

dicionario_por_pinyin : dicionario_por_pinyin.pdf dicionario_por_pinyin_livreto.pdf

dicionario_por_tracos : dicionario_por_tracos.pdf dicionario_por_tracos_livreto.pdf

$(PVERBTAR) : 
	echo Already done...

$(SVERBTAR) : 
	echo Already done...

entries_by_pinyin.tar.gz : $(PVERBTAR)
	cp entries_by_pinyin.tar.gz backup/entries_by_pinyin.tar.gz.${TIMESTAMP}
	cp $(PVERBTAR) .
	rm -f ${PVERBDIR}/* ${PGRPDIR}/*

entries_by_strokes.tar.gz : $(PVERBTAR)
	cp entries_by_strokes.tar.gz backup/entries_by_strokes.tar.gz.${TIMESTAMP}
	cp $(SVERBTAR) .
	rm -f ${SVERBDIR}/* ${SGRPDIR}/*

pinyin : pinyin.pdf
	cp pinyin.pdf ${BKPDIR}/pinyin.pdf.${TIMESTAMP}

strokes: strokes.pdf
	cp strokes.pdf $(BKPDIR)/strokes.pdf.$(TIMESTAMP)

$(INCDIR)/%.tex :
	echo Already done...

$(PVERBDIR)/%.tex : entries_by_pinyin.tar.gz
	tar xvzf entries_by_pinyin.tar.gz

$(SVERBDIR)/%.tex : entries_by_strokes.tar.gz
	tar xvzf entries_by_strokes.tar.gz

$(PGRPDIR)/%.tex : $(PVERBDIR)/%.tex
	$(PGENGRP) -r $(PVERBDIR) -w $(PGRPDIR)

$(SGRPDIR)/%.tex : $(SVERBDIR)/%.tex
	$(SGENGRP) -r $(SVERBDIR) -w $(SGRPDIR)

pinyin.pdf : pinyin.tex $(INCDIR)/%.tex $(PGRPDIR)/%.tex
	$(TEX) pinyin.tex
	$(TEX) pinyin.tex
	echo -n "Verbetes: "
	@grep begin $(PVERBDIR)/* | grep entries | wc -l

strokes.pdf : strokes.tex $(INCDIR)/%.tex $(SGRPDIR)/%.tex
	$(TEX) strokes.tex
	$(TEX) strokes.tex
	echo -n "Verbetes: "
	@grep begin $(SVERBDIR)/* | grep entries | wc -l

pinyin-booklet.pdf : pinyin.pdf
	$(BOOK) pinyin.pdf

strokes-booklet.pdf : strokes.pdf
	$(BOOK) strokes.pdf

dicionario_por_pinyin.pdf : pinyin.pdf
	cp pinyin.pdf dicionario_por_pinyin.pdf

dicionario_por_tracos.pdf : strokes.pdf
	cp strokes.pdf dicionario_por_tracos.pdf

dicionario_por_pinyin_livreto.pdf : pinyin-booklet.pdf
	cp pinyin-booklet.pdf dicionario_por_pinyin_livreto.pdf

dicionario_por_tracos_livreto.pdf : strokes-booklet.pdf
	cp strokes-booklet.pdf dicionario_por_tracos_livreto.pdf

deploy-pinyin : dicionario_por_pinyin.pdf dicionario_por_pinyin_livreto.pdf
	cp dicionario_por_pinyin.pdf         $(DSTSITE)
	cp dicionario_por_pinyin_livreto.pdf $(DSTSITE)
	cp dicionario_por_pinyin.pdf         $(DSTREPO)
	cp dicionario_por_pinyin_livreto.pdf $(DSTREPO)

deploy-strokes : dicionario_por_tracos.pdf dicionario_por_tracos_livreto.pdf
	cp dicionario_por_tracos.pdf         $(DSTSITE)
	cp dicionario_por_tracos_livreto.pdf $(DSTSITE)
	cp dicionario_por_tracos.pdf         $(DSTREPO)
	cp dicionario_por_tracos_livreto.pdf $(DSTREPO)

deploy : deploy-pinyin deploy-strokes

total:
	@echo -n "***** Verbetes Pinyin: "
	@grep begin $(PVERBDIR)/* | grep entries | wc -l
	@echo -n "\***** Verbetes Tracos: "
	@grep begin $(SVERBDIR)/* | grep entries | wc -l


clean :
	rm -f $(ALLDIR)/*.tex
	rm -f $(PVERBDIR)/*.tex $(PGRPDIR)/*.tex
	rm -f $(SVERBDIR)/*.tex $(SGRPDIR)/*.tex
	rm -f *.aux *.idx *.ilg *.ind *.log *.toc *.out


