FROM ghcr.io/ptero-eggs/installers:debian

RUN apt-get update \
    && apt-get install -y --no-install-recommends git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY terminal.sh /usr/local/share/sky/terminal.sh
COPY sky-install /usr/local/bin/sky-install
RUN chmod 755 /usr/local/bin/sky-install /usr/local/share/sky/terminal.sh
