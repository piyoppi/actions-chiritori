FROM alpine:3.14

RUN apk add --no-cache wget gnu-libiconv jq git

RUN wget https://github.com/piyoppi/chiritori/releases/download/v1.4.1/chiritori-linux-x86_64-musl.tar.gz && \
  tar -zxvf chiritori-linux-x86_64-musl.tar.gz && \
  rm chiritori-linux-x86_64-musl.tar.gz && \
  cp chiritori /usr/local/bin/chiritori && \
  rm -rf target && \
  apk del wget

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
