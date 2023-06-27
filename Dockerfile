#
# NOTE: THIS DOCKERFILE IS GENERATED FROM "Dockerfile.template" VIA
# "generate-dockerfiles.sh".
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.18.2 as builder

WORKDIR /build

# Common dependencies
RUN apk update
RUN apk add bash git build-base make cmake ninja curl zlib-dev patch linux-headers python3 python3-dev

# The following are needed because we are going to change some autoconf scripts,
# both for libnghttp2 and curl.
RUN apk add autoconf automake pkgconfig libtool

# Dependencies for downloading and building BoringSSL
RUN apk add g++ go

# Download and compile libbrotli
ARG BROTLI_VERSION=1.0.9
RUN curl -L https://github.com/google/brotli/archive/refs/tags/v${BROTLI_VERSION}.tar.gz -o brotli-${BROTLI_VERSION}.tar.gz && \
    tar xf brotli-${BROTLI_VERSION}.tar.gz
RUN cd brotli-${BROTLI_VERSION} && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=./installed .. && \
    cmake --build . --config Release --target install

# BoringSSL doesn't have versions. Choose a commit that is used in a stable
# Chromium version.
ARG BORING_SSL_VERSION=fips-20220613
RUN curl -L https://github.com/google/boringssl/archive/refs/tags/${BORING_SSL_VERSION}.tar.gz -o brotli-ssl-${BORING_SSL_VERSION}.tar.gz && \
    tar xf brotli-ssl-${BORING_SSL_VERSION}.tar.gz

# Compile BoringSSL.
# See https://boringssl.googlesource.com/boringssl/+/HEAD/BUILDING.md
COPY patches/boringssl-*.patch boringssl-${BORING_SSL_VERSION}/
RUN cd boringssl-${BORING_SSL_VERSION} && \
    for p in $(ls boringssl-*.patch); do patch -p1 < $p; done && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=on -GNinja .. && \
    ninja

# Fix the directory structure so that curl can compile against it.
# See https://everything.curl.dev/source/build/tls/boringssl
RUN mkdir boringssl-${BORING_SSL_VERSION}/build/lib && \
    ln -s ../crypto/libcrypto.a boringssl-${BORING_SSL_VERSION}/build/lib/libcrypto.a && \
    ln -s ../ssl/libssl.a boringssl-${BORING_SSL_VERSION}/build/lib/libssl.a && \
    cp -R boringssl-${BORING_SSL_VERSION}/include boringssl-${BORING_SSL_VERSION}/build

ARG NGHTTP2_VERSION=1.54.0
ARG NGHTTP2_URL=https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.gz

# Download nghttp2 for HTTP/2.0 support.
RUN curl -o nghttp2-${NGHTTP2_VERSION}.tar.gz -L ${NGHTTP2_URL}
RUN tar xf nghttp2-${NGHTTP2_VERSION}.tar.gz

# Compile nghttp2
RUN cd nghttp2-${NGHTTP2_VERSION} && \
    ./configure --prefix=/build/nghttp2-${NGHTTP2_VERSION}/installed --with-pic --disable-shared && \
    make && make install

# Download curl.

#ARG CURL_VERSION=7.84.0
#ARG CURL_URL=https://github.com/curl/curl/releases/download/curl-7_84_0/curl-${CURL_VERSION}.tar.gz

#ARG CURL_VERSION=7.85.0
#ARG CURL_URL=https://github.com/curl/curl/releases/download/curl-7_85_0/curl-${CURL_VERSION}.tar.gz

#ARG CURL_VERSION=7.86.0
#ARG CURL_URL=https://github.com/curl/curl/releases/download/curl-7_86_0/curl-${CURL_VERSION}.tar.gz

#ARG CURL_VERSION=7.87.0
#ARG CURL_URL=https://github.com/curl/curl/releases/download/curl-7_87_0/curl-${CURL_VERSION}.tar.gz

ARG CURL_VERSION=7.88.1
ARG CURL_URL=https://github.com/curl/curl/releases/download/curl-7_88_1/curl-${CURL_VERSION}.tar.gz

RUN curl -o curl-${CURL_VERSION}.tar.xz -L ${CURL_URL}
RUN tar xf curl-${CURL_VERSION}.tar.xz

# Patch curl and re-generate the configure script
COPY patches/curl-${CURL_VERSION}-*.patch curl-${CURL_VERSION}/
RUN cd curl-${CURL_VERSION} && \
    for p in $(ls curl-*.patch); do patch -p1 < $p; done && \
    autoreconf -fi

# Compile curl with nghttp2, libbrotli and nss (firefox) or boringssl (chrome).
# Enable keylogfile for debugging of TLS traffic.
RUN cd curl-${CURL_VERSION} && \
    ./configure --prefix=/build/install \
                --enable-static \
                --disable-shared \
                --with-nghttp2=/build/nghttp2-${NGHTTP2_VERSION}/installed \
                --with-brotli=/build/brotli-${BROTLI_VERSION}/build/installed \
                --with-openssl=/build/boringssl-${BORING_SSL_VERSION}/build \
                LIBS="-pthread" \
                CFLAGS="-I/build/boringssl-${BORING_SSL_VERSION}/build" \
                USE_CURL_SSLKEYLOGFILE=true && \
    make && make install

RUN mkdir out && \
    cp /build/install/bin/curl-impersonate-chrome out/ && \
    ln -s curl-impersonate-chrome out/curl-impersonate && \
    ln -s curl-impersonate-chrome out/curl-chromium && \
    strip out/curl-impersonate-chrome

# Verify that the resulting 'curl' has all the necessary features.
RUN ./out/curl-impersonate-chrome -V | grep -q zlib && \
    ./out/curl-impersonate-chrome -V | grep -q brotli && \
    ./out/curl-impersonate-chrome -V | grep -q nghttp2 && \
    ./out/curl-impersonate-chrome -V | grep -q -e NSS -e BoringSSL

# Verify that the resulting 'curl' is really statically compiled
RUN ! (ldd ./out/curl-impersonate-chrome | grep -q -e libcurl -e nghttp2 -e brotli -e ssl -e crypto)

RUN rm -Rf /build/install

# Re-compile libcurl dynamically
RUN cd curl-${CURL_VERSION} && \
    ./configure --prefix=/build/install \
                --with-nghttp2=/build/nghttp2-${NGHTTP2_VERSION}/installed \
                --with-brotli=/build/brotli-${BROTLI_VERSION}/build/installed \
                --with-openssl=/build/boringssl-${BORING_SSL_VERSION}/build \
                LIBS="-pthread" \
                CFLAGS="-I/build/boringssl-${BORING_SSL_VERSION}/build" \
                USE_CURL_SSLKEYLOGFILE=true && \
    make clean && make && make install

# Copy libcurl-chromium and symbolic links
RUN cp -d /build/install/lib/libcurl-impersonate* /build/out

RUN ver=$(readlink -f curl-${CURL_VERSION}/lib/.libs/libcurl-impersonate-chrome.so | sed 's/.*so\.//') && \
    major=$(echo -n $ver | cut -d'.' -f1) && \
    ln -s "libcurl-impersonate-chrome.so.$ver" "out/libcurl-impersonate.so.$ver" && \
    ln -s "libcurl-impersonate.so.$ver" "out/libcurl-impersonate.so" && \
    strip "out/libcurl-impersonate.so.$ver"

# Verify that the resulting 'libcurl' is really statically compiled against its
# dependencies.
RUN ! (ldd ./out/curl-impersonate | grep -q -e nghttp2 -e brotli -e ssl -e crypto)

# Wrapper scripts
COPY ./bin/curl_chrome* ./bin/curl_edge* ./bin/curl_safari* out/
# Replace /usr/bin/env bash with /usr/bin/env ash
RUN sed -i 's@/usr/bin/env bash@/usr/bin/env ash@' out/curl_*
RUN chmod +x out/curl_*

# Create a final, minimal image with the compiled binaries
# only.
FROM alpine:3.18.2
# Copy curl-chromium from the builder image
COPY --from=builder /build/install /usr/local
# Wrapper scripts
COPY --from=builder /build/out/curl* /usr/local/bin/