# -------- Stage 1: build --------
FROM alpine:3.20 AS build

# Build dependencies
RUN apk add --no-cache git build-base cmake libuv-dev openssl-dev

# Optional: pin XMRig-proxy version at build time (e.g., v6.21.0)
# docker build --build-arg XMRIG_PROXY_VERSION=v6.21.0 -t xmrig-proxy:mini .
ARG XMRIG_PROXY_VERSION=
WORKDIR /src

# Shallow clone (specific tag if provided, otherwise default branch)
RUN if [ -n "$XMRIG_PROXY_VERSION" ]; then git clone --depth=1 --branch "$XMRIG_PROXY_VERSION" https://github.com/xmrig/xmrig-proxy.git . ; else git clone --depth=1 https://github.com/xmrig/xmrig-proxy.git . ; fi

# Build in Release
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DWITH_TLS=ON && cmake --build build -- -j"$(nproc)" && strip build/xmrig-proxy

# -------- Stage 2: runtime --------
FROM alpine:3.20

# Runtime libraries only
RUN apk add --no-cache libuv openssl libstdc++ && adduser -D -H -s /sbin/nologin xmrig-proxy

# Copy binary
COPY --from=build /src/build/xmrig-proxy /usr/local/bin/xmrig-proxy

USER xmrig-proxy
WORKDIR /work

# Environment variables for pool configuration
ENV POOL_URL="" \
    POOL_USER="" \
    POOL_PASS="x" \
    DONATE_LEVEL="1" \
    TLS_ENABLED="false" \
    TLS_FINGERPRINT="" \
    PROXY_PORT="3333"

# Use config.json mounted at /work if desired
ENTRYPOINT ["sh", "-c", "xmrig-proxy \
    --url \"${POOL_URL}\" \
    --user \"${POOL_USER}\" \
    --pass \"${POOL_PASS}\" \
    --donate-level \"${DONATE_LEVEL}\" \
    ${TLS_ENABLED:+--tls} \
    ${TLS_FINGERPRINT:+--tls-fingerprint \"${TLS_FINGERPRINT}\"} \
    --bind 0.0.0.0:${PROXY_PORT} \
    \"$@\"", "--"]

CMD []
