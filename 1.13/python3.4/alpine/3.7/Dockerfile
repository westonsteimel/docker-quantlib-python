FROM quay.io/westonsteimel/quantlib:1.13-alpine3.7 as ql
FROM python:3.4-alpine3.7 as ql-python

COPY --from=ql /usr/local/lib/libQuantLib.la /usr/local/lib/
COPY --from=ql /usr/local/lib/libQuantLib.so.0.0.0 /usr/local/lib/
COPY --from=ql /usr/local/bin/quantlib-config /usr/local/bin/
COPY --from=ql /usr/local/include/ /usr/local/include/
COPY --from=ql /usr/include /usr/include

RUN cd /usr/local/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so.0
RUN cd /usr/local/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so

RUN ldconfig /usr/local/lib

ARG CONCURRENT_PROCESSES=1
ARG QUANTLIB_SWIG_VERSION=1.13
ARG QUANTLIB_SWIG_DIR=quantlib_swig
ARG QUANTLIB_SWIG_CHECKSUM=0ab99d6a43b2a204d6366fb600aa3cd049ee29e1d0406fefaedcc0f4fd9c65c2
ENV QUANTLIB_SWIG_VERSION=${QUANTLIB_SWIG_VERSION}
ENV QUANTLIB_SWIG_CHECKSUM=${QUANTLIB_SWIG_CHECKSUM}

RUN mkdir -p ${QUANTLIB_SWIG_DIR} \
    && apk --no-cache upgrade \
    && apk --no-cache add --virtual .build-dependencies \
    linux-headers \
    build-base \
    automake \
    autoconf \
    libtool \
    curl \
    swig \
    tar \
    && cd ${QUANTLIB_SWIG_DIR} \
    && curl -L --retry 3 https://github.com/lballabio/QuantLib-SWIG/releases/download/QuantLib-SWIG-v${QUANTLIB_SWIG_VERSION}/QuantLib-SWIG-${QUANTLIB_SWIG_VERSION}.tar.gz -o quantlib-swig.tar.gz \
    && echo "${QUANTLIB_SWIG_CHECKSUM}  quantlib-swig.tar.gz" | sha256sum -c \
    && tar -xzf quantlib-swig.tar.gz --strip 1 \
    && ./configure --disable-perl --disable-ruby --disable-csharp --disable-r --disable-java CXXFLAGS=-O3 \
    && make -j ${CONCURRENT_PROCESSES} -C Python && make install \
    && cd .. && rm -rf ${QUANTLIB_SWIG_DIR} \
    && apk del .build-dependencies \
    && rm -rf /var/cache/*

FROM python:3.4-alpine3.7
LABEL Description="An environment with the QuantLib Python module"

ARG PYTHON_LIB_PATH=python3.4
ARG QUANTLIB_SWIG_VERSION=1.13
ENV QUANTLIB_SWIG_VERSION ${QUANTLIB_SWIG_VERSION}

COPY --from=ql-python /usr/local/lib/libQuantLib.la /usr/local/lib/
COPY --from=ql-python /usr/local/lib/libQuantLib.so.0.0.0 /usr/local/lib/
COPY --from=ql-python /usr/local/lib/${PYTHON_LIB_PATH}/site-packages/QuantLib* \
                    /usr/local/lib/${PYTHON_LIB_PATH}/site-packages/

RUN addgroup -g 1000 quantlib \
    && adduser -u 1000 -G quantlib -s /bin/sh -D quantlib \
    && apk --no-cache upgrade \
    && apk --no-cache add libstdc++ \
    && cd /usr/local/lib \
    && ln -s libQuantLib.so.0.0.0 libQuantLib.so.0 \
    && ln -s libQuantLib.so.0.0.0 libQuantLib.so \
    && ldconfig /usr/local/lib \
    && chmod -R +x /usr/local/lib/

USER quantlib

CMD ["python"]

