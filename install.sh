#!/bin/bash
#
# File:         install.sh
# Created:      200517
#
# Master install script for GPAW.
#

### FUNCTIONS ###

libxc_install()
{
 $GPAW/sh/build-libxc.sh
 return $?
}

blas_install()
{
 $GPAW/sh/build-blas.sh
 return $?
}

libxc_test()
{
 typeset _l="$GPAW/software"
 typeset uninstalled=0

 [ ! -f "$_l/include/xc.h" -o ! -f "$_l/lib/libxc.a" ] && uninstalled=1

 [ "$uninstalled" -ne 0 ] && { echo "building and installing libxc"; libxc_install; return $?; }

 echo "libxc already installed."
 return 0
}

blas_test()
{
 typeset _l="$GPAW/software"
 typeset uninstalled=0

 [ ! -f "$_l/lib/libblas.so" ] && uninstalled=1

 [ "$uninstalled" -eq 1 ] && { blas_install; return $?; }

 echo "blas already installed."
 return 0
}

#
#
lapack_test()
{
 typeset libs="liblapack.a librefblas.a libtmglib.a"
 typeset _l="$GPAW/software/lib"
 typeset fp=""
 typeset uninstalled=0

 for lib in $libs
 do
  fp="${_l}/${lib}"

  [ ! -f "$fp" ] && { uninstalled=1; break; }
 done

 [ "$uninstalled" -eq 1 ] &&
 {
  $GPAW/sh/build-lapack.sh
  return $?
 }

 echo "lapack already installed."
 return 0
}

### ENV ###

 export GPAW="${GPAW:-$1}"
 [ -z "$GPAW" ] && { echo "usage: $0 install path";  exit 1; }
 [ ! -d "$GPAW" ] && { echo "Creating install path $GPAW"; mkdir $GPAW; [ $? -ne 0 ] && exit 1; } 

 # this is temporary... for real!
 mkdir -p $GPAW/sh
 cp *.sh $GPAW/sh

 export workDir="$GPAW/software"
 mkdir -p "$workDir"
 mkdir -p "$workDir/lib"
 mkdir -p "$workDir/bin"
 mkdir -p "$workDir/include"

 export PATH="$workDir/bin:$PATH"
 export virtualenv="${GPAWENV:-$GPAW/software/venv}"
 export activate="$virtualenv/bin/activate"

 # this can be improved... another day...
 pythons="/app/httpd/bin/python3 $GPAW/software/bin/python3 \
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

# test if libxc is installed if not build/install

 blas_test || exit $?
 lapack_test || exit $?
 libxc_test || exit $?
 echo

 export LAPACK="$GPAW/software/lib"
 export LAPACK_SRC="$GPAW/source/lapack"
 export BLAS="$GPAW/software/lib"

 # the next lines are due to incorrect handling of dependencies by packages
 #
 # defining LDFLAGS breaks numpy build
 # module: numpy/linalg/lapack_lite.cpython-37m-x86_64-linux-gnu.so
 # error: undefined reference to main
 # CFLAGS with include directory is needed by "GPAW" for libxc headers
 pip install -U numpy   &&
 pip install -U ase     &&
 pip install -U setuptools_scm      # setuptools_scm needed by "elastic"

 LDFLAGS="-L${workDir}/lib -Wl,-rpath=${workDir}/lib -Wl,-rpath=/usr/lib"     \
 CFLAGS="-I${workDir}/include"  \
 pip install -U -r $GPAW/requirements.txt

### EOF ###
