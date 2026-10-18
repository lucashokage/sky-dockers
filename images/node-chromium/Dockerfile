ARG NODE_VERSION=22
FROM ghcr.io/ptero-eggs/yolks:nodejs_${NODE_VERSION}

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends chromium fonts-liberation fonts-noto-color-emoji fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    CHROME_PATH=/usr/bin/chromium \
    CHROME_BIN=/usr/bin/chromium

USER container
