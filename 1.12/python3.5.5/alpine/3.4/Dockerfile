FROM westonsteimel/quantlib:1.12-alpine3.4 as ql
FROM python:3.5.5-alpine3.4 as ql-python

COPY --from=ql /usr/lib/libQuantLib.la /usr/lib/
COPY --from=ql /usr/lib/libQuantLib.so.0.0.0 /usr/lib/
COPY --from=ql /usr/bin/quantlib-config /usr/bin/
COPY --from=ql /usr/include/ /usr/include/
RUN cd /usr/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so.0
RUN cd /usr/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so

RUN ldconfig /usr/lib

ARG QUANTLIB_SWIG_VERSION=1.12
ARG QUANTLIB_SWIG_DIR=quantlib_swig
ENV QUANTLIB_SWIG_VERSION ${QUANTLIB_SWIG_VERSION}

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
    && curl -sL --retry 3 http://downloads.sourceforge.net/project/quantlib/QuantLib/${QUANTLIB_SWIG_VERSION}/other\ languages/QuantLib-SWIG-${QUANTLIB_SWIG_VERSION}.tar.gz | \
    tar -xz --strip 1 -C ${QUANTLIB_SWIG_DIR}/ \
    && cd ${QUANTLIB_SWIG_DIR} \
    && ./configure --disable-perl --disable-ruby --disable-csharp --disable-r --disable-java CXXFLAGS=-O3 \
    && make && make install \
    && cd .. && rm -rf ${QUANTLIB_SWIG_DIR} \
    && apk del .build-dependencies \
    && rm -rf /var/cache/*

FROM python:3.5.5-alpine3.4
LABEL Description="An environment with the QuantLib Python module"

ARG PYTHON_LIB_PATH=python3.5
ENV QUANTLIB_SWIG_VERSION ${QUANTLIB_SWIG_VERSION}

RUN apk --no-cache add libstdc++

COPY --from=ql-python /usr/lib/libQuantLib.la /usr/lib/
COPY --from=ql-python /usr/lib/libQuantLib.so.0.0.0 /usr/lib/
RUN cd /usr/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so.0
RUN cd /usr/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so
RUN ldconfig /usr/lib

COPY --from=ql-python /usr/local/lib/${PYTHON_LIB_PATH}/site-packages/QuantLib* \
                    /usr/local/lib/${PYTHON_LIB_PATH}/site-packages/

CMD ["python"]

