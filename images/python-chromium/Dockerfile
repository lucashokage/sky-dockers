ARG PYTHON_VERSION=3.12
FROM ghcr.io/ptero-eggs/yolks:python_${PYTHON_VERSION}

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends chromium chromium-driver fonts-liberation fonts-noto-color-emoji fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

ENV CHROME_PATH=/usr/bin/chromium \
    CHROME_BIN=/usr/bin/chromium \
    CHROMEDRIVER_PATH=/usr/bin/chromedriver

USER container
