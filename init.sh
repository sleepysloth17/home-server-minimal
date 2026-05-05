#!/bin/bash

HOME_PATH=/home
CONFIG_FOLDER_NAME=config

DELUGE_SERVICE_NAME="deluge"
PROFILARR_SERVICE_NAME="profilarr"
RADARR_SERVICE_NAME="radarr"
SONARR_SERVICE_NAME="sonarr"
PROWLARR_SERVICE_NAME="prowlarr"
FLARESOLVERR_SERVICE_NAME="flaresolverr"
JELLYFIN_SERVICE_NAME="jellyfin"

function prompt() {
  local question="$1"
  local value

  read -r -p "$question" value

  echo "$value"
}

function mkdirAndPermissions() {
  local path="$1"
  local owner="$2"
  local group="$3"

  # mkdir -p "$path"

  # chown -R "$owner":"$group" "$path"
  # chmod g+w "$path"
}

function createUser() {
  local username="$1"

  # sudo useradd -m "$username"
  # sudo usermod -L "$username"
  # sudo usermod -a -G "$username" "$USER"

  # echo "$(id -u "$username")" "$(id -g "$username")"
  echo "u-$username" "g-$username"
}

function createConfigAndUser() {
  local service="$1"

  read -r user_id group_id < <(createUser "$service")

  local home_location="${HOME_PATH}/${service}"
  local config_location="${home_location}/${CONFIG_FOLDER_NAME}"

  mkdirAndPermissions "$config_location" "$service" "$service"

  echo "$user_id" "$group_id" "$config_location"
}

function createJellyfinConfigAndCache() {
  local service="$1"

  read -r user_id group_id config_location < <(createConfigAndUser "$service")

  local cache_folder_name="cache"
  local cache_location="${HOME_PATH}/${service}/${cache_folder_name}"

  mkdirAndPermissions "$cache_location" "$service" "$service"

  echo "$user_id" "$group_id" "$config_location" "$cache_location"
}

function createDelugeConfig() {
  local service="$1"
  local download_path="$2"

  read -r user_id group_id config_location < <(createConfigAndUser "$service")

  local download_location="${download_path}/${service}"
  local in_progress="in-progress"
  local completed="completed"

  mkdirAndPermissions "${download_location}/${in_progress}" "$service" "$service"
  mkdirAndPermissions "${download_location}/${completed}" "$service" "$service"

  echo "$user_id" "$group_id" "$config_location" "$download_location"
}

function createArrConfig() {
  local service="$1"
  local media_location="$2"

  read -r user_id group_id config_location < <(createConfigAndUser "$service")
  
  mkdirAndPermissions "$media_location" "$service" "$USER"

  echo "$user_id" "$group_id" "$config_location"
}

read -r wireguard_private_key < <(prompt "Wireguard private key: ")
read -r download_path < <(prompt "Download path: ")
read -r tv_path < <(prompt "TV path: ")
read -r movies_path < <(prompt "Movie path: ")

read -r deluge_user_id deluge_group_id deluge_config_location download_location < <(createDelugeConfig $DELUGE_SERVICE_NAME "$download_path")
read -r jellyfin_user_id jellyfin_group_id jellyfin_config_location jellyfin_cache_location < <(createJellyfinConfigAndCache $JELLYFIN_SERVICE_NAME)

read -r radarr_user_id radarr_group_id radarr_config_location < <(createArrConfig $RADARR_SERVICE_NAME "$movies_path")
read -r sonarr_user_id sonarr_group_id sonarr_config_location < <(createArrConfig $SONARR_SERVICE_NAME "$tv_path")

read -r profilarr_user_id profilarr_group_id profilarr_config_location < <(createConfigAndUser $PROFILARR_SERVICE_NAME)
read -r prowlarr_user_id prowlarr_group_id prowlarr_config_location < <(createConfigAndUser $PROWLARR_SERVICE_NAME)
read -r flaresolverr_user_id flaresolverr_group_id < <(createUser $FLARESOLVERR_SERVICE_NAME)

export WIREGUARD_PRIVATE_KEY="$wireguard_private_key"

export DELUGE_USER_ID="$deluge_user_id"
export DELUGE_GROUP_ID="$deluge_group_id"
export DELUGE_CONFIG_LOCATION="$deluge_config_location"
export DELUGE_DOWNLOAD_LOCATION="$download_location"

export JELLYFIN_USER_ID="$jellyfin_user_id"
export JELLYFIN_GROUP_ID="$jellyfin_group_id"
export JELLYFIN_CONFIG_LOCATION="$jellyfin_config_location"
export JELLYFIN_CACHE_LOCATION="$jellyfin_cache_location"
export JELLYFIN_MEDIA_LOCATION_MOVIES_1="$movies_path"
export JELLYFIN_MEDIA_LOCATION_TV_1="$tv_path"

export RADARR_USER_ID="$radarr_user_id"
export RADARR_GROUP_ID="$radarr_group_id"
export RADARR_CONFIG_LOCATION="$radarr_config_location"
export RADARR_MOVIES_LOCATION="$movies_path"
export RADARR_DOWNLOADS_LOCATION="$download_location"

export SONARR_USER_ID="$sonarr_user_id"
export SONARR_GROUP_ID="$sonarr_group_id"
export SONARR_CONFIG_LOCATION="$sonarr_config_location"
export SONARR_TV_LOCATION="$tv_path"
export SONARR_DOWNLOADS_LOCATION="$download_location"

export PROFILARR_USER_ID="$profilarr_user_id"
export PROFILARR_GROUP_ID="$profilarr_group_id"
export PROFILARR_CONFIG_LOCATION="$profilarr_config_location"

export PROWLARR_USER_ID="$prowlarr_user_id"
export PROWLARR_GROUP_ID="$prowlarr_group_id"
export PROWLARR_CONFIG_LOCATION="$prowlarr_config_location"

export FLARESOLVERR_USER_ID="$flaresolverr_user_id"
export FLARESOLVERR_GROUP_ID="$flaresolverr_group_id"

# shellcheck disable=SC2016
VARS='$WIREGUARD_PRIVATE_KEY
$DELUGE_USER_ID $DELUGE_GROUP_ID $DELUGE_CONFIG_LOCATION $DELUGE_DOWNLOAD_LOCATION
$PROFILARR_USER_ID $PROFILARR_GROUP_ID $PROFILARR_CONFIG_LOCATION
$RADARR_USER_ID $RADARR_GROUP_ID $RADARR_CONFIG_LOCATION $RADARR_MOVIES_LOCATION $RADARR_DOWNLOADS_LOCATION
$SONARR_USER_ID $SONARR_GROUP_ID $SONARR_CONFIG_LOCATION $SONARR_TV_LOCATION $SONARR_DOWNLOADS_LOCATION
$PROWLARR_USER_ID $PROWLARR_GROUP_ID $PROWLARR_CONFIG_LOCATION
$FLARESOLVERR_USER_ID $FLARESOLVERR_GROUP_ID
$JELLYFIN_USER_ID $JELLYFIN_GROUP_ID $JELLYFIN_CONFIG_LOCATION $JELLYFIN_CACHE_LOCATION $JELLYFIN_MEDIA_LOCATION_MOVIES_1 $JELLYFIN_MEDIA_LOCATION_TV_1'

envsubst "$VARS" < .env.tmpl > .env