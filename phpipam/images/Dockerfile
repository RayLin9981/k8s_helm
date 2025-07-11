FROM docker.io/phpipam/phpipam-www:latest

# 複製你的 CA 憑證
COPY fck8slab-rootca.crt /usr/local/share/ca-certificates/

# 安裝 ca-certificates 並更新信任清單
RUN apk add --no-cache ca-certificates curl \
 && update-ca-certificates

