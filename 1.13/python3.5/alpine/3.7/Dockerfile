FROM quay.io/westonsteimel/quantlib:1.13-alpine3.7 as ql
FROM python:3.5-alpine3.7 as ql-python

COPY --from=ql /usr/local/lib/libQuantLib.la /usr/local/lib/
COPY --from=ql /usr/local/lib/libQuantLib.so.0.0.0 /usr/local/lib/
COPY --from=ql /usr/local/bin/quantlib-config /usr/local/bin/
COPY --from=ql /usr/local/include/ /usr/local/include/
COPY --from=ql /usr/include /usr/include

RUN cd /usr/local/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so.0
RUN cd /usr/local/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so

RUN ldconfig /usr/local/lib

ARG QUANTLIB_SWIG_VERSION=1.13
ARG QUANTLIB_SWIG_DIR=quantlib_swig
ENV QUANTLIB_SWIG_VERSION=${QUANTLIB_SWIG_VERSION}

RUN mkdir -p ${QUANTLIB_SWIG_DIR} \
    && apk --no-cache add --virtual .build-dependencies \
    linux-headers \
    build-base \
    automake \
    autoconf \
    libtool \
    curl \
    swig \
    tar \
    && curl -sL --retry 3 https://github.com/lballabio/QuantLib-SWIG/releases/download/QuantLib-SWIG-v${QUANTLIB_SWIG_VERSION}/QuantLib-SWIG-${QUANTLIB_SWIG_VERSION}.tar.gz | \
    tar -xz --strip 1 -C ${QUANTLIB_SWIG_DIR}/ \
    && cd ${QUANTLIB_SWIG_DIR} \
    && ./configure --disable-perl --disable-ruby --disable-csharp --disable-r --disable-java CXXFLAGS=-O3 \
    && make -C Python && make install \
    && cd .. && rm -rf ${QUANTLIB_SWIG_DIR} \
    && apk del .build-dependencies \
    && rm -rf /var/cache/*

FROM python:3.5-alpine3.7
LABEL Description="An environment with the QuantLib Python module"

ARG PYTHON_LIB_PATH=python3.5
ARG QUANTLIB_SWIG_VERSION=1.13
ENV QUANTLIB_SWIG_VERSION ${QUANTLIB_SWIG_VERSION}

RUN apk --no-cache add libstdc++

COPY --from=ql-python /usr/local/lib/libQuantLib.la /usr/local/lib/
COPY --from=ql-python /usr/local/lib/libQuantLib.so.0.0.0 /usr/local/lib/
RUN cd /usr/local/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so.0
RUN cd /usr/local/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so
RUN ldconfig /usr/local/lib

COPY --from=ql-python /usr/local/lib/${PYTHON_LIB_PATH}/site-packages/QuantLib* \
                    /usr/local/lib/${PYTHON_LIB_PATH}/site-packages/

CMD ["python"]

