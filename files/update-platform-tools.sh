#!/usr/bin/env sh
set -eu

# Usage: update-platform-tools.sh [VERSION [SHA1]]
# Without arguments the latest stable version is installed.
install_platform_tools() {
  local VERSION="${1:-}"
  local SHA1="${2:-}"
  local URL="https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
  if [ -n "${VERSION}" ]; then
    URL="https://dl.google.com/android/repository/platform-tools_r${VERSION}-linux.zip"
  fi
  local TMPFILE=$(mktemp)

  mkdir -p /opt
  echo "Fetching ${URL}" >&2
  wget -O "${TMPFILE}" "${URL}"

  if [ -n "${SHA1}" ]; then
    echo "Verifying checksum" >&2
    echo "${SHA1}  ${TMPFILE}" | sha1sum -c -
  fi

  echo "Removing previous version of platform tools if any" >&2
  rm -rf /opt/platform-tools

  echo "Unpacking platform tools" >&2
  unzip -d /opt "${TMPFILE}"
  rm "${TMPFILE}"

  local INSTALLED_VERSION=$(grep Revision /opt/platform-tools/source.properties |cut -d '=' -f 2)
  echo "Platform tools version: ${INSTALLED_VERSION} installed!" >&2
}

install_platform_tools "$@"
