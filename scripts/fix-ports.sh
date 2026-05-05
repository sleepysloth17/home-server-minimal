#!/bin/bash

CONTAINER_PREFIX=home-server-

function findForwardedPort() {
  local port_file="/tmp/gluetun/forwarded_port"
  local file_exists_command="if [ -f "$port_file" ]; then cat $port_file; fi"
  docker exec -t "${CONTAINER_PREFIX}gluetun-1" sh -c "$file_exists_command";
}

function findCurrentConfiguredPort() {
  local get_config='/usr/bin/deluge-console -c /config "config listen_ports"'
  local port=$(docker exec -t "${CONTAINER_PREFIX}deluge-1" sh -c "$get_config" | \
    grep "listen_ports" | \
    sed -rn 's/listen_ports: \(([0-9]*), \1\)/\1/p')
  echo ${port%$'\r'} # remove trailing carriage return
}

function updateDelugePort() {
  local new_port=$1
  local update_config="/usr/bin/deluge-console -c /config \"config --set listen_ports ($new_port,$new_port)\""
  echo "Updating deluge port to $new_port"
  docker exec -t "${CONTAINER_PREFIX}deluge-1" sh -c "$update_config"
}

CURRENT_FORWARDED_PORT=$(findForwardedPort)

if [ -z "$CURRENT_FORWARDED_PORT" ];
then
  echo "No ports forwarded, restarting gluetun"
  # restart gluetun and the rest of the containers as we need to reforward
  docker restart "${CONTAINER_PREFIX}gluetun-1" "${CONTAINER_PREFIX}deluge-1"
  # now update the deluge port
  updateDelugePort $(findForwardedPort)
else
  echo "Current gluetun port: $CURRENT_FORWARDED_PORT"

  CURRENT_DELUGE_CONFIGURED_PORT=$(findCurrentConfiguredPort)
  echo "Current deluge port: $CURRENT_DELUGE_CONFIGURED_PORT"

  if [ "$CURRENT_FORWARDED_PORT" != "$CURRENT_DELUGE_CONFIGURED_PORT" ];
  then
    updateDelugePort $CURRENT_FORWARDED_PORT
  else
    echo "Ports match, nothing to configure"
  fi
fi
docker exec -t home-server-gluetun-1 sh -c "if [ -f /tmp/gluetun/forwarded_port ]; then cat /tmp/gluetun/forwarded_port; fi"
echo ""
