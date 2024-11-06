TIMESTAMP != date "+%FT%T%z"

TEX = lualatex -halt-on-error -8bit # -papersize=A4 -interaction=batchmode
MKIDX = ~/.local/bin/zhmakeindex -s ./config/dicionario.ist
BOOK = pdfjam --landscape --signature 20 --twoside --a4paper --suffix livreto

INCDIR = ./include
BKPDIR = ./backup
DSTSITE = /var/www/ler.cordeiro.nom.br/dicionario
DSTREPO = /var/www/repo.ler.cordeiro.nom.br/Dicionário

PISOLATE = ./bin/isolatebypinyin.py
PGENGRP = ./bin/gengroupsbypinyin.py
PVERBTAR = ~/Documentos/Chinês/DCP/verbetes_por_pinyin.tar.gz
PVERBDIR = ./verbetes_por_pinyin
PGRPDIR = ./grupos_por_pinyin

SISOLATE = ./bin/isolatebystrokes.py
SGENGRP = ./bin/gengroupsbystrokes.py
SVERBTAR = ~/Documentos/Chinês/DCP/verbetes_por_tracos.tar.gz
SVERBDIR = ./verbetes_por_tracos
SGRPDIR = ./grupos_por_tracos
 
all : dicionario_por_pinyin.pdf dicionario_por_pinyin_livreto.pdf dicionario_por_tracos.pdf dicionario_por_tracos_livreto.pdf

$(PVERBTAR) : 
	echo Already done...

$(SVERBTAR) : 
	echo Already done...

verbetes_por_pinyin.tar.gz : $(PVERBTAR)
	cp verbetes_por_pinyin.tar.gz backup/verbetes_por_pinyin.tar.gz.${TIMESTAMP}
	cp $(PVERBTAR) .
	rm -f ${PVERBDIR}/* ${PGRPDIR}/*

verbetes_por_tracos.tar.gz : $(PVERBTAR)
	cp verbetes_por_tracos.tar.gz backup/verbetes_por_tracos.tar.gz.${TIMESTAMP}
	cp tracos.pdf backup/tracos.pdf.${TIMESTAMP}
	cp $(SVERBTAR) .
	rm -f ${SVERBDIR}/* ${SGRPDIR}/*

pinyin : pinyin.pdf
	cp pinyin.pdf ${BKPDIR}/pinyin.pdf.${TIMESTAMP}

tracos: tracos.pdf
	cp tracos.pdf $(BKPDIR)/tracos.pdf.$(TIMESTAMP)

$(INCDIR)/%.tex :
	echo Already done...

$(PVERBDIR)/%.tex : verbetes_por_pinyin.tar.gz
	tar xvzf verbetes_por_pinyin.tar.gz

$(SVERBDIR)/%.tex : verbetes_por_tracos.tar.gz
	tar xvzf verbetes_por_tracos.tar.gz

$(PGRPDIR)/%.tex : $(PVERBDIR)/%.tex
	$(PGENGRP) -r $(PVERBDIR) -w $(PGRPDIR)

$(SGRPDIR)/%.tex : $(SVERBDIR)/%.tex
	$(SGENGRP) -r $(SVERBDIR) -w $(SGRPDIR)

pinyin.pdf : pinyin.tex $(INCDIR)/%.tex $(PGRPDIR)/%.tex
	$(TEX) pinyin.tex
	$(MKIDX) -z bihua pstroke
	$(MKIDX) -z bushou pradical
	$(TEX) pinyin.tex
	$(TEX) pinyin.tex
	echo -n "Verbetes: "
	@grep begin $(PVERBDIR)/* | grep verbete | wc -l

tracos.pdf : tracos.tex $(INCDIR)/%.tex $(SGRPDIR)/%.tex verbetes_por_tracos.tar.gz
	$(TEX) tracos.tex
	$(MKIDX) -z bushou sradical
	$(TEX) tracos.tex
	$(TEX) tracos.tex
	echo -n "Verbetes: "
	@grep begin $(SVERBDIR)/* | grep verbete | wc -l

pinyin-livreto.pdf : pinyin.pdf
	$(BOOK) pinyin.pdf

tracos-livreto.pdf : tracos.pdf
	$(BOOK) tracos.pdf

dicionario_por_pinyin.pdf : pinyin.pdf
	cp pinyin.pdf dicionario_por_pinyin.pdf

dicionario_por_tracos.pdf : tracos.pdf
	cp tracos.pdf dicionario_por_tracos.pdf

dicionario_por_pinyin_livreto.pdf : pinyin-livreto.pdf
	cp pinyin-livreto.pdf dicionario_por_pinyin_livreto.pdf

dicionario_por_tracos_livreto.pdf : tracos-livreto.pdf
	cp tracos-livreto.pdf dicionario_por_tracos_livreto.pdf

deploy : dicionario_por_pinyin.pdf dicionario_por_tracos.pdf dicionario_por_pinyin_livreto.pdf dicionario_por_tracos_livreto.pdf
	cp dicionario_por_pinyin.pdf         $(DSTSITE)
	cp dicionario_por_pinyin.pdf         $(DSTREPO)
	cp dicionario_por_pinyin_livreto.pdf $(DSTSITE)
	cp dicionario_por_pinyin_livreto.pdf $(DSTREPO)
	cp dicionario_por_tracos.pdf         $(DSTSITE)
	cp dicionario_por_tracos.pdf         $(DSTREPO)
	cp dicionario_por_tracos_livreto.pdf $(DSTSITE)
	cp dicionario_por_tracos_livreto.pdf $(DSTREPO)

total :
	@echo -n "***** Verbetes Pinyin: "
	@grep begin $(PVERBDIR)/* | grep verbete | wc -l
	@echo -n "\***** Verbetes Tracos: "
	@grep begin $(SVERBDIR)/* | grep verbete | wc -l


clean :
	rm -f *.aux *.idx *.ilg *.ind *.log *.toc *.out
	rm -f $(ALLDIR)/verbetes.tex
	rm -f $(PVERBDIR)/*.tex $(PGRPDIR)/*.tex
	rm -f $(SVERBDIR)/*.tex $(SGRPDIR)/*.tex


