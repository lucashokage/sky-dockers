FROM ghcr.io/ptero-eggs/yolks:debian_bookworm

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx php-fpm php-cli php-mysql php-sqlite3 php-curl php-gd php-mbstring php-xml php-zip php-intl php-bcmath unzip \
    && rm -rf /var/lib/apt/lists/*

COPY sky-web /usr/local/bin/sky-web
RUN chmod 755 /usr/local/bin/sky-web

USER container
