#!/bin/bash

echo "Jellyfin IP:"

docker run --network=container:home-server-jellyfin-1 --rm -i alpine sh -c "apk add curl jq && curl https://am.i.mullvad.net/json | jq";

echo "Deluge IP:"

docker run --network=container:home-server-deluge-1 --rm -i alpine sh -c "apk add curl jq && curl https://am.i.mullvad.net/json | jq";

echo "Done"
