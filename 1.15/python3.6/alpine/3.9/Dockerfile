FROM quay.io/westonsteimel/quantlib:1.15-alpine3.9 as ql
FROM python:3.6-alpine3.9 as ql-python

COPY --from=ql /usr/local/lib/libQuantLib.la /usr/local/lib/
COPY --from=ql /usr/local/lib/libQuantLib.so.0.0.0 /usr/local/lib/
COPY --from=ql /usr/local/bin/quantlib-config /usr/local/bin/
COPY --from=ql /usr/local/include/ /usr/local/include/
COPY --from=ql /usr/include /usr/include

RUN cd /usr/local/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so.0
RUN cd /usr/local/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so

RUN ldconfig /usr/local/lib

ARG CONCURRENT_PROCESSES=1
ARG QUANTLIB_SWIG_VERSION=1.15
ARG QUANTLIB_SWIG_DIR=quantlib_swig
ARG QUANTLIB_SWIG_CHECKSUM=bb177822d473c8bd87579ef39b261ca32227fb5492ebd5e21db2e8f090cbc8c6
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
    ca-certificates \
    && cd ${QUANTLIB_SWIG_DIR} \
    && curl -fSL --retry 3 https://github.com/lballabio/QuantLib-SWIG/releases/download/QuantLib-SWIG-v${QUANTLIB_SWIG_VERSION}/QuantLib-SWIG-${QUANTLIB_SWIG_VERSION}.tar.gz -o quantlib-swig.tar.gz \
    && echo "${QUANTLIB_SWIG_CHECKSUM}  quantlib-swig.tar.gz" | sha256sum -c \
    && tar -xzf quantlib-swig.tar.gz --strip 1 \
    && cd Python \
    && CXXFLAGS='-g0 -O3' python setup.py bdist_wheel \
    && apk del .build-dependencies \
    && rm -rf /var/cache/*

FROM python:3.6-alpine3.9
LABEL description="An Alpine Linux environment with the QuantLib Python module"

ARG PYTHON_LIB_PATH=python3.6
ARG QUANTLIB_SWIG_VERSION=1.15
ENV QUANTLIB_SWIG_VERSION ${QUANTLIB_SWIG_VERSION}

COPY --from=ql-python /usr/local/lib/libQuantLib.la /usr/local/lib/
COPY --from=ql-python /usr/local/lib/libQuantLib.so.0.0.0 /usr/local/lib/
COPY --from=ql-python /quantlib_swig/Python/dist/QuantLib_Python*.whl /tmp

RUN addgroup -g 1000 quantlib \
    && adduser -u 1000 -G quantlib -s /bin/sh -D quantlib \
    && apk --no-cache upgrade \
    && apk --no-cache add libstdc++ \
    && cd /usr/local/lib \
    && ln -s libQuantLib.so.0.0.0 libQuantLib.so.0 \
    && ln -s libQuantLib.so.0.0.0 libQuantLib.so \
	&& pip install /tmp/QuantLib_Python*.whl \
    && ldconfig /usr/local/lib \
    && chmod -R +x /usr/local/lib/

USER quantlib

CMD ["python"]

