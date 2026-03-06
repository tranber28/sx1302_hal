# Image de base ARM pour Raspberry Pi
FROM balenalib/raspberry-pi-debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    build-essential \
    libgpiod-dev \
    gpiod \
    gcc \
    g++ \
    make \
    cmake \
    wget \
    curl \
    ca-certificates \
    pkg-config \
    libftdi1-dev \
    libusb-1.0-0-dev \
    mosquitto \
    mosquitto-clients \
    libmosquitto-dev \
  && rm -rf /var/lib/apt/lists/*

# Créer le répertoire de travail
WORKDIR /opt/sx1302_hal

# Copier ton code local dans le container
COPY . /opt/sx1302_hal
RUN chmod +x /opt/sx1302_hal/packet_forwarder/reset_lgw.sh
RUN sed -i 's/DEBUG_FTIME= 0/DEBUG_FTIME= 0\nCFG_SX1302= 0\nCFG_SX1303= 1/' libloragw/library.cfg
# Compiler la bibliothèque et les outils
RUN make clean && make CFG_SX1303=1 CFG_SX1302=0
# Créer le répertoire pour les fichiers de configuration
RUN mkdir -p /opt/sx1302_hal/config

# Copier les fichiers de configuration par défaut
RUN cp packet_forwarder/global_conf.json.sx1250.* /opt/sx1302_hal/config/ || true

# Exposer le répertoire de configuration comme volume
VOLUME ["/opt/sx1302_hal/config"]

# Définir le répertoire de travail pour le packet forwarder
WORKDIR /opt/sx1302_hal/packet_forwarder

# Script de démarrage par défaut
CMD ["sh", "-c", "./reset_lgw.sh start && ./lora_pkt_fwd -c /opt/sx1302_hal/config/global_conf.json"]
