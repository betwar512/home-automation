# bin/bash

docker compose -b homeassistant -f ha.yml up -d && \
docker compose -b media-server -f mediaserver.yml up -d && \
docker compose -v manager -f portainer.yml up -d


