
ARG BASE=dellelce/uwsgi
FROM ${BASE}:latest as build

LABEL maintainer="Antonio Dell'Elce"

ENV SPACY         /app/spacy
ENV BUILDDIR      ${SPACY}/build
ENV SPACYINSTALL  ${SPACY}/software

# Packages description here
# MATPLOTLIB:  needed by ase
ENV AUTOTOOLS   autoconf automake perl
ENV COMPILERS   gcc g++ make
ENV COREDEV     libc-dev linux-headers make

ENV PACKAGES wget bash ${COMPILERS}  ${AUTOTOOLS}

WORKDIR $BUILDDIR

COPY requirements.txt $SPACY

RUN  apk add --no-cache  $PACKAGES

# Second Stage
ARG BASE=dellelce/uwsgi
FROM ${BASE}:latest AS final

ENV SPACY            /app/spacy

RUN mkdir -p "${SPACY}"/software

COPY --from=build ${SPACY}/software ${SPACY}/software
