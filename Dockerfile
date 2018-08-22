
ARG BASE=dellelce/mkit
FROM ${BASE}:latest as build

LABEL maintainer="Antonio Dell'Elce"

ENV GPAW         /app/gpaw
ENV BUILDDIR     ${GPAW}/build
ENV GPAWINSTALL  ${GPAW}/software

# Packages description here
# MATPLOTLIB:  needed by ase
ENV MATPLOTLIB  freetype-dev libpng-dev
ENV AUTOTOOLS   autoconf automake perl
ENV COMPILERS   gcc g++ gfortran make
ENV COREDEV     libc-dev linux-headers make

ENV PACKAGES wget bash ${COMPILERS} ${MATPLOTLIB} ${AUTOTOOLS}

WORKDIR $BUILDDIR
COPY *.sh $BUILDDIR/

# these three directories are prepared by "getcomponents.sh"
COPY blas   $GPAW/source/blas
COPY lapack $GPAW/source/lapack
COPY libxc  $GPAW/source/libxc

COPY requirements.txt $GPAW

RUN  apk add --no-cache  $PACKAGES &&  \
     bash ${BUILDDIR}/docker.sh $GPAW

# Second Stage
ARG BASE=dellelce/mkit
FROM ${BASE}:latest AS final

ENV GPAW            /app/gpaw
ENV GPAW_SETUP_PATH ${GPAW}/datasets

VOLUME ${GPAW_SETUP_PATH}
VOLUME ${GPAW}/executions

RUN mkdir -p "${GPAW}"/software

RUN  apk add --no-cache libgfortran libstdc++

# ain't this dirty?
ENV LD_PRELOAD /usr/lib/libgfortran.so.3

COPY --from=build ${GPAW}/software ${GPAW}/software
