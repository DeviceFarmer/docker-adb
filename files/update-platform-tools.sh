#!/usr/bin/env sh
set -euo pipefail

install_platform_tools() {
  local URL="https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
  local TMPFILE=$(mktemp)

  mkdir -p /opt
  echo "Fetching ${URL}" >&2
  wget -O "${TMPFILE}" "${URL}"

  echo "Removing previous version of platform tools if any" >&2
  rm -rf /opt/platform-tools

  echo "Unpacking platform tools" >&2
  unzip -d /opt "${TMPFILE}"
  rm "${TMPFILE}"

  local VERSION=$(grep Revision /opt/platform-tools/source.properties |cut -d '=' -f 2)
  echo "Platform tools version: ${VERSION} installed!" >&2
}

install_platform_tools
