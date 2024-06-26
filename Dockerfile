FROM alpine:3.14

RUN apk add --no-cache wget gnu-libiconv

RUN wget https://github.com/piyoppi/chiritori/releases/download/v0.3.0/x86_64-unknown-linux-musl.tar.gz && \
  tar -zxvf x86_64-unknown-linux-musl.tar.gz && \
  rm x86_64-unknown-linux-musl.tar.gz && \
  cp target/x86_64-unknown-linux-musl/release/chiritori /usr/local/bin/chiritori && \
  rm -rf target && \
  apk del wget

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
