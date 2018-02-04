FROM westonsteimel/quantlib:1.12-alpine3.7 as ql
FROM python:3.6.4-alpine3.7 as ql-python

COPY --from=ql /usr/lib/libQuantLib.la /usr/lib/
COPY --from=ql /usr/lib/libQuantLib.so.0.0.0 /usr/lib/
COPY --from=ql /usr/bin/quantlib-config /usr/bin/
COPY --from=ql /usr/include/ /usr/include/
RUN cd /usr/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so.0
RUN cd /usr/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so

RUN #apk add --no-cache --virtual .build-dependencies \
    #linux-headers \
    #build-base \
    #autoconf \
    #libtool \
    ldconfig /usr/lib
    #&& cd .. && rm -rf ${QUANTLIB_DIR} \
    #&& apk del .build-dependencies

#RUN ldconfig

#RUN apk add --no-cache python3 python3-dev swig

ARG QUANTLIB_SWIG_VERSION=1.12
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
    swig \
    && curl -sL --retry 3 http://downloads.sourceforge.net/project/quantlib/QuantLib/${QUANTLIB_SWIG_VERSION}/other\ languages/QuantLib-SWIG-${QUANTLIB_SWIG_VERSION}.tar.gz | \
    tar -xz --strip 1 -C ${QUANTLIB_SWIG_DIR}/ \
    && cd ${QUANTLIB_SWIG_DIR} \
    && ./configure --disable-perl --disable-ruby --disable-csharp --disable-r --disable-java CXXFLAGS=-O3 \
    && make && make install \
    && cd .. && rm -rf ${QUANTLIB_SWIG_DIR} \
    && apk del .build-dependencies 

#CMD ["python"]

FROM python:3.6.4-alpine3.7
LABEL Description="An environment with the QuantLib Python module"

ENV QUANTLIB_SWIG_VERSION ${QUANTLIB_SWIG_VERSION}

RUN apk add --no-cache libstdc++

COPY --from=ql-python /usr/lib/libQuantLib.la /usr/lib/
COPY --from=ql-python /usr/lib/libQuantLib.so.0.0.0 /usr/lib/
RUN cd /usr/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so.0
RUN cd /usr/lib && ln -s libQuantLib.so.0.0.0 libQuantLib.so
RUN ldconfig /usr/lib

COPY --from=ql-python /usr/local/lib/python3.6/site-packages/QuantLib* \
                    /usr/local/lib/python3.6/site-packages/
#COPY --from=ql-python /usr/local/lib/python3.6/site-packages/QuantLib*.egg-info \
#                    /usr/local/lib/python3.6/site-packages/

CMD ["python"]

