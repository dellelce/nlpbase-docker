
ARG BASE=dellelce/uwsgi
FROM ${BASE}:latest as build

LABEL maintainer="Antonio Dell'Elce"

ENV NLP         /app/nlp
ENV BUILDDIR    ${NLP}/build
ENV NLPINSTALL  ${NLP}/software

# Packages description here
ENV AUTOTOOLS   autoconf automake perl
ENV COMPILERS   gcc g++ make
ENV COREDEV     libc-dev linux-headers make
ENV PILLOWDEV   zlib-dev libxml2-dev libjpeg jpeg-dev libxslt-dev libxslt

ENV PACKAGES wget bash ${COMPILERS} ${AUTOTOOLS} ${PILLOWDEV}

WORKDIR $BUILDDIR
COPY *.sh $BUILDDIR/

COPY requirements.txt $NLP

RUN  apk add --no-cache  $PACKAGES &&  \
     bash ${BUILDDIR}/docker.sh $NLP

# Second Stage
ARG BASE=dellelce/uwsgi
FROM ${BASE}:latest AS final

ENV NLP         /app/nlp
ENV BINDEPS     libstdc++ libjpeg zlib libxslt

RUN mkdir -p "${NLP}"/software && \
    apk add --no-cache ${BINDEPS}

COPY --from=build ${NLP}/software ${NLP}/software
