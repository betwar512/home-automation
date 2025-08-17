# bin/bash

docker compose -p homeassistant -f ha.yml up -d && \
docker compose -p media-server -f mediaserver.yml up -d && \
docker compose -p manager -f portainer.yaml up -d
