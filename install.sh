#!/bin/bash
#
# File:         install.sh
# Created:      220818
#
# Master install script for SPACY.
#

### ENV ###

 export SPACY="${SPACY:-$1}"
 [ -z "$SPACY" ] && { echo "usage: $0 install path";  exit 1; }
 [ ! -d "$SPACY" ] && { echo "Creating install path $SPACY"; mkdir $SPACY; [ $? -ne 0 ] && exit 1; } 

 # this is temporary... for real!
 mkdir -p $SPACY/sh
 cp *.sh $SPACY/sh

 export workDir="$SPACY/software"
 mkdir -p "$workDir"
 mkdir -p "$workDir/lib"
 mkdir -p "$workDir/bin"
 mkdir -p "$workDir/include"

 export PATH="$workDir/bin:$PATH"
 export virtualenv="${SPACYENV:-$SPACY/software/venv}"
 export activate="$virtualenv/bin/activate"

 # this can be improved... another day...
 pythons="/app/httpd/bin/python3 $SPACY/software/bin/python3 \
          /usr/local/bin/python3 /usr/bin/python3"
 [ -d "$prefix" ] && export pythons="$prefix/bin/python3 $pythons"
 [ -d "/app/uwsgi" ] && export pythons="/app/uwsgi/bin/python3 $pythons"

 for p in $pythons
 do
  [ -e "$p" ] && { python="$p"; break; }
 done

### MAIN ###

 $python -m venv $virtualenv || { echo "Python virtualenv creation failed!"; exit 1; }
 [ ! -f "$activate" ] && { echo "virtualenv activate does not exist!"; exit 1; }

 . "$activate"
 pip install -U pip setuptools

 LDFLAGS="-L${workDir}/lib -Wl,-rpath=${workDir}/lib -Wl,-rpath=/usr/lib"     \
 CFLAGS="-I${workDir}/include"  \
 pip install -U -r $SPACY/requirements.txt

### EOF ###
