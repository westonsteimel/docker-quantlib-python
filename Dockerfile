FROM westonsteimel/quantlib:1.11-alpine3.7
LABEL description="QuantLib with Python on Alpine Linux."

RUN apk add --no-cache python3 python3-dev swig

ARG QUANTLIB_SWIG_VERSION=1.11
ARG QUANTLIB_SWIG_DIR=quantlib_swig
ENV QUANTLIB_SWIG_VERSION ${QUANTLIB_SWIG_VERSION}

RUN mkdir -p ${QUANTLIB_SWIG_DIR} \
    && apk add --no-cache --virtual .build-dependencies \
    linux-headers \
    build-base \
    automake \
    autoconf \
    libtool \
    curl \
    && curl -sL --retry 3 http://downloads.sourceforge.net/project/quantlib/QuantLib/${QUANTLIB_SWIG_VERSION}/other\ languages/QuantLib-SWIG-${QUANTLIB_SWIG_VERSION}.tar.gz | \
    tar -xz --strip 1 -C ${QUANTLIB_SWIG_DIR}/ \
    && cd ${QUANTLIB_SWIG_DIR} \
    && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi \
    && if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi \
    && ./configure --disable-perl --disable-ruby --disable-mzscheme --disable-guile --disable-csharp --disable-ocaml --disable-r --disable-java CXXFLAGS=-O3 \
    && make && make install \
    && cd .. && rm -rf ${QUANTLIB_SWIG_DIR} \
    && apk del .build-dependencies 


CMD ["python"]

