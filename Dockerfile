FROM alpine:3.14

RUN apk add --no-cache wget gnu-libiconv

RUN wget https://github.com/piyoppi/chiritori/releases/download/v0.2.0/x86_64-unknown-linux-musl.tar.gz && \
  tar -zxvf x86_64-unknown-linux-musl.tar.gz && \
  rm x86_64-unknown-linux-musl.tar.gz && \
  cp target/x86_64-unknown-linux-musl/release/chiritori /usr/local/bin/chiritori && \
  rm -rf target && \
  apk del wget

RUN mkdir /app
WORKDIR /app

COPY entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
