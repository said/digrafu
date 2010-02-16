#!/bin/sh
# Compilador C utilizado e argumentos. Atualmente, configurado para otimizar.
CC=cc

ARGS=-O4

# pastas onde encontrar fontes e onde salvar executaveis
EXE=./Exe
SRC=./Sources

cd ${0%/compile.sh}		# independente de onde foi executado o .sh
mkdir -p $EXE

	# compilando bionj
	echo "$CC $ARGS -o $EXE/bionj $SRC/bionj.c"
	$CC $ARGS -o $EXE/bionj $SRC/bionj.c

	# compilando dnadist
	echo "$CC  -c $ARGS $SRC/dnadist.c -o $SRC/dnadist.o"
	$CC  -c $ARGS $SRC/dnadist.c -o $SRC/dnadist.o
	echo "$CC  -c $ARGS $SRC/seq.c -o $SRC/seq.o"
	$CC  -c $ARGS $SRC/seq.c -o $SRC/seq.o
	echo "$CC  -c $ARGS $SRC/phylip.c -o $SRC/phylip.o"
	$CC  -c $ARGS $SRC/phylip.c -o $SRC/phylip.o
	
	echo "$CC  $ARGS $SRC/dnadist.o $SRC/seq.o $SRC/phylip.o -lm -o $EXE/dnadist"
	$CC  $ARGS $SRC/dnadist.o $SRC/seq.o $SRC/phylip.o -lm -o $EXE/dnadist

	# compilando upgma
	echo "$CC  -c $ARGS $SRC/neighbor.c -o $SRC/neighbor.o"
	$CC  -c $ARGS $SRC/neighbor.c -o $SRC/neighbor.o
	echo "$CC  -c $ARGS $SRC/dist.c -o $SRC/dist.o"
	$CC  -c $ARGS $SRC/dist.c -o $SRC/dist.o
	
	echo "$CC  $ARGS $SRC/neighbor.o $SRC/dist.o $SRC/phylip.o -lm -o $EXE/upgma"
	$CC  $ARGS $SRC/neighbor.o $SRC/dist.o $SRC/phylip.o -lm -o $EXE/upgma
	
	# compilando protdist
	echo "$CC  -c $ARGS $SRC/protdist.c -o $SRC/protdist.o"
	$CC  -c $ARGS $SRC/protdist.c -o $SRC/protdist.o

	echo "$CC  $ARGS $SRC/protdist.o $SRC/seq.o $SRC/phylip.o -lm -o $EXE/protdist"
	$CC  $ARGS $SRC/protdist.o $SRC/seq.o $SRC/phylip.o -lm -o $EXE/protdist
	
	# compilando weighbor
	cd $SRC
	make
	cd ..
	mv $SRC/weighbor $EXE/
	
	# compilando fastme
	cd $SRC/fastme1.1
	make
	cd ../..
	mv $SRC/fastme1.1/fastme $EXE/
	
	# clean
	echo "Limpando."
	rm -f $SRC/*.o $SRC/*/*.o
	echo "Feito."
	
