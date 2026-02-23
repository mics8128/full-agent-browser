FROM lscr.io/linuxserver/chromium:latest

RUN apt-get update && apt-get install -y socat && rm -rf /var/lib/apt/lists/*

COPY root/ /
