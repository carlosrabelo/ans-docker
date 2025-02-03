# -------- Stage 1: build --------
FROM alpine:3.20 AS build

# Build dependencies
RUN apk add --no-cache git build-base cmake libuv-dev openssl-dev hwloc-dev

# Optional: pin XMRig version at build time (e.g., v6.21.2)
# docker build --build-arg XMRIG_VERSION=v6.21.2 -t xmrig:mini .
ARG XMRIG_VERSION=
WORKDIR /src

# Shallow clone (specific tag if provided, otherwise default branch)
RUN if [ -n "$XMRIG_VERSION" ]; then git clone --depth=1 --branch "$XMRIG_VERSION" https://github.com/xmrig/xmrig.git . ; else git clone --depth=1 https://github.com/xmrig/xmrig.git . ; fi

# Build in Release
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DWITH_HWLOC=ON -DWITH_TLS=ON && cmake --build build -- -j"$(nproc)" && strip build/xmrig

# -------- Stage 2: runtime --------
FROM alpine:3.20

# Runtime libraries only
RUN apk add --no-cache libuv openssl hwloc libstdc++ && adduser -D -H -s /sbin/nologin xmrig

# Copy binary
COPY --from=build /src/build/xmrig /usr/local/bin/xmrig

USER xmrig
WORKDIR /work

# Use config.json mounted at /work if desired
ENTRYPOINT ["xmrig"]

CMD ["--help"]
