FROM alpine:3.18.6

# Set up insecure default key
RUN mkdir -m 0750 /root/.android
ADD files/insecure_shared_adbkey /root/.android/adbkey
ADD files/insecure_shared_adbkey.pub /root/.android/adbkey.pub
ADD files/update-platform-tools.sh /usr/local/bin/update-platform-tools.sh

RUN set -xeo pipefail && \
    apk update && \
    apk add wget ca-certificates tini && \
    wget -O "/etc/apk/keys/sgerrand.rsa.pub" \
      "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub" && \
     wget -O "/tmp/glibc.apk" \
      "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-2.35-r1.apk" && \
     wget -O "/tmp/glibc-bin.apk" \
      "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-bin-2.35-r1.apk" && \
     apk add "/tmp/glibc.apk" "/tmp/glibc-bin.apk" && \
     rm "/etc/apk/keys/sgerrand.rsa.pub" && \
     rm "/root/.wget-hsts" && \
     rm "/tmp/glibc.apk" "/tmp/glibc-bin.apk" && \
     rm -r /var/cache/apk/APKINDEX.* && \
    mkdir -p /lib64 && \
    ln -sf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2 && \
    /usr/local/bin/update-platform-tools.sh

# Expose default ADB port
EXPOSE 5037

# Set up PATH
ENV PATH $PATH:/opt/platform-tools

# Hook up tini as the default init system for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Start the server by default
CMD ["adb", "-a", "-P", "5037", "server", "nodaemon"]
