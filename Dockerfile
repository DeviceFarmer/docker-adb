FROM debian:trixie-slim

# Bumped automatically by .github/workflows/platform-tools-update.yml
ARG PLATFORM_TOOLS_VERSION=37.0.3
ARG PLATFORM_TOOLS_SHA1=e1579b288a7ae4e9bc28dedec6a154d78b3c04ed

# Set up insecure default key
RUN mkdir -m 0750 /root/.android
COPY files/insecure_shared_adbkey /root/.android/adbkey
COPY files/insecure_shared_adbkey.pub /root/.android/adbkey.pub
COPY files/update-platform-tools.sh /usr/local/bin/update-platform-tools.sh

RUN set -xeo pipefail && \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates wget unzip tini && \
    rm -rf /var/lib/apt/lists/* && \
    /usr/local/bin/update-platform-tools.sh "${PLATFORM_TOOLS_VERSION}" "${PLATFORM_TOOLS_SHA1}"

# Expose default ADB port
EXPOSE 5037

# Set up PATH
ENV PATH=$PATH:/opt/platform-tools

# Hook up tini as the default init system for proper signal handling
ENTRYPOINT ["/usr/bin/tini", "--"]

# Start the server by default
CMD ["adb", "-a", "-P", "5037", "server", "nodaemon"]
