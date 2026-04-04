FROM lsiobase/kasmvnc:ubuntujammy

ARG ANKI_VERSION=25.09.2
ENV ANKI_HOME=/tmp/Anki2
ARG ANKI_CONNECT_VERSION=25.2.25.0

COPY anki-home ${ANKI_HOME}

RUN \
  apt-get update && \
  apt-get install -y anki wget zstd xdg-utils libxcb-xinerama0 libxcb-cursor0 && \
  dpkg --remove anki && \
  wget https://github.com/ankitects/anki/releases/download/${ANKI_VERSION}/anki-${ANKI_VERSION}-linux-qt6.tar.zst && \
  tar --use-compress-program=unzstd -xvf anki-${ANKI_VERSION}-linux-qt6.tar.zst && \
  cd anki-${ANKI_VERSION}-linux-qt6 && ./install.sh &&  cd .. && \
  rm -rf anki-${ANKI_VERSION}-linux-qt6 anki-${ANKI_VERSION}-linux-qt6.tar.zst && \
  apt-get clean && \
  anki -b ${ANKI_HOME} -v && \
  mkdir -p ${ANKI_HOME}/addons21/2055492159 && mkdir -p /tmp/anki-connect-extracted && \
  wget -O /tmp/anki-connect.tar.gz https://git.sr.ht/~foosoft/anki-connect/archive/${ANKI_CONNECT_VERSION}.tar.gz && \
  tar -xzf /tmp/anki-connect.tar.gz -C /tmp/anki-connect-extracted --strip-components=1 && \
  cp -v -r /tmp/anki-connect-extracted/plugin/* ${ANKI_HOME}/addons21/2055492159/ && \
  rm /tmp/anki-connect.tar.gz

COPY ankiconnect-config.json ${ANKI_HOME}/addons21/2055492159/config.json

VOLUME /config

COPY ./root /
