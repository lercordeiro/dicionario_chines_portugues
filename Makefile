TIMESTAMP != date "+%FT%T%z"

TEX = lualatex -halt-on-error -8bit # -papersize=A4 -interaction=batchmode
BOOK = pdfjam --a4paper --landscape --twoside --signature 20 --suffix booklet --

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
 
RGENGRP = ./bin/gengroupsbyradicals.py
RVERBTAR = ~/Documentos/Chinês/DCP/entries_by_radicals.tar.gz
RVERBDIR = ./entries_by_radicals
RGRPDIR = ./groups_by_radicals
 
all : dicionario_por_pinyin dicionario_por_tracos dicionario_por_radicais

dicionario_por_pinyin : dicionario_por_pinyin.pdf dicionario_por_pinyin_livreto.pdf

dicionario_por_tracos : dicionario_por_tracos.pdf dicionario_por_tracos_livreto.pdf

dicionario_por_radicais : dicionario_por_radicais.pdf dicionario_por_radicais_livreto.pdf

$(PVERBTAR) : 
	echo Already done...

$(SVERBTAR) : 
	echo Already done...

$(RVERBTAR) : 
	echo Already done...

entries_by_pinyin.tar.gz : $(PVERBTAR)
	touch entries_by_pinyin.tar.gz
	cp entries_by_pinyin.tar.gz backup/entries_by_pinyin.tar.gz.${TIMESTAMP}
	cp $(PVERBTAR) .
	rm -f ${PVERBDIR}/* ${PGRPDIR}/*

entries_by_strokes.tar.gz : $(SVERBTAR)
	touch entries_by_strokes.tar.gz
	cp entries_by_strokes.tar.gz backup/entries_by_strokes.tar.gz.${TIMESTAMP}
	cp $(SVERBTAR) .
	rm -f ${SVERBDIR}/* ${SGRPDIR}/*

entries_by_radicals.tar.gz : $(RVERBTAR)
	touch entries_by_radicals.tar.gz
	cp entries_by_radicals.tar.gz backup/entries_by_radicals.tar.gz.${TIMESTAMP}
	cp $(RVERBTAR) .
	rm -f ${RVERBDIR}/* ${RGRPDIR}/*

pinyin : pinyin.pdf
	touch pinyin.pdf
	cp pinyin.pdf ${BKPDIR}/pinyin.pdf.${TIMESTAMP}

strokes: strokes.pdf
	touch strokes.pdf
	cp strokes.pdf $(BKPDIR)/strokes.pdf.$(TIMESTAMP)

radicals: radicals.pdf
	touch radicals.pdf
	cp radicals.pdf $(BKPDIR)/radicals.pdf.$(TIMESTAMP)

$(INCDIR)/%.tex :
	echo Already done...

$(PVERBDIR)/%.tex : entries_by_pinyin.tar.gz
	tar xvzf entries_by_pinyin.tar.gz

$(SVERBDIR)/%.tex : entries_by_strokes.tar.gz
	tar xvzf entries_by_strokes.tar.gz

$(RVERBDIR)/%.tex : entries_by_radicals.tar.gz
	tar xvzf entries_by_radicals.tar.gz

$(PGRPDIR)/%.tex : $(PVERBDIR)/%.tex
	$(PGENGRP) -r $(PVERBDIR) -w $(PGRPDIR)

$(SGRPDIR)/%.tex : $(SVERBDIR)/%.tex
	$(SGENGRP) -r $(SVERBDIR) -w $(SGRPDIR)

$(RGRPDIR)/%.tex : $(RVERBDIR)/%.tex
	$(RGENGRP) -r $(RVERBDIR) -w $(RGRPDIR)

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

radicals.pdf : radicals.tex $(INCDIR)/%.tex $(RGRPDIR)/%.tex
	$(TEX) radicals.tex
	$(TEX) radicals.tex
	echo -n "Verbetes: "
	@grep begin $(RVERBDIR)/* | grep entries | wc -l

pinyin-booklet.pdf : pinyin.pdf
	$(BOOK) pinyin.pdf

strokes-booklet.pdf : strokes.pdf
	$(BOOK) strokes.pdf

radicals-booklet.pdf : radicals.pdf
	$(BOOK) radicals.pdf

dicionario_por_pinyin.pdf : pinyin.pdf
	cp pinyin.pdf dicionario_por_pinyin.pdf

dicionario_por_tracos.pdf : strokes.pdf
	cp strokes.pdf dicionario_por_tracos.pdf

dicionario_por_radicais.pdf : radicals.pdf
	cp radicals.pdf dicionario_por_radicais.pdf

dicionario_por_pinyin_livreto.pdf : pinyin-booklet.pdf
	cp pinyin-booklet.pdf dicionario_por_pinyin_livreto.pdf

dicionario_por_tracos_livreto.pdf : strokes-booklet.pdf
	cp strokes-booklet.pdf dicionario_por_tracos_livreto.pdf

dicionario_por_radicais_livreto.pdf : radicals-booklet.pdf
	cp radicals-booklet.pdf dicionario_por_radicais_livreto.pdf

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

deploy-radicals : dicionario_por_radicais.pdf dicionario_por_radicais_livreto.pdf
	cp dicionario_por_radicais.pdf         $(DSTSITE)
	cp dicionario_por_radicais_livreto.pdf $(DSTSITE)
	cp dicionario_por_radicais.pdf         $(DSTREPO)
	cp dicionario_por_radicais_livreto.pdf $(DSTREPO)

deploy : deploy-pinyin deploy-strokes deploy-radicals

total:
	@echo -n "***** Verbetes Pinyin: "
	@grep begin $(PVERBDIR)/* | grep entries | wc -l
	@echo -n "\***** Verbetes Tracos: "
	@grep begin $(SVERBDIR)/* | grep entries | wc -l
	@echo -n "\***** Verbetes Radicais: "
	@grep begin $(RVERBDIR)/* | grep entries | wc -l


clean :
	rm -f $(ALLDIR)/*.tex
	rm -f $(PVERBDIR)/*.tex $(PGRPDIR)/*.tex
	rm -f $(SVERBDIR)/*.tex $(SGRPDIR)/*.tex
	rm -f $(RVERBDIR)/*.tex $(RGRPDIR)/*.tex
	rm -f *.aux *.idx *.ilg *.ind *.log *.toc *.out

