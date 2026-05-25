FROM balenalib/raspberry-pi-debian-python:3-bookworm-run

WORKDIR /usr/app
COPY pip.conf /etc/

RUN install_packages\
  gcc \
  python3-dev \
  curl \
  cron \
  libatlas3-base \
  libopenblas0 \
  libgfortran5 \
  libzstd1 \
  liblcms2-2 \
  libjbig0 \
  libopenjp2-7 \
  libwebpdemux2 \
  libtiff6 \
  libwebpmux3 \
  libwebp7 \
  libxcb1 \
  libfreetype6-dev \
  jq 

COPY requirements.txt .
RUN python3 -m venv --without-pip /opt/venv && \
    curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/venv/bin/python3 && \
    /opt/venv/bin/pip install -r requirements.txt

ENV PATH="/opt/venv/bin:$PATH"

COPY start.sh .
COPY run-update.sh .
COPY lib lib
COPY fonts fonts
COPY weather-icons weather-icons

RUN chmod +x start.sh
RUN chmod +x run-update.sh

COPY update-display.py .

CMD ["/bin/bash","start.sh"]

ENV DEVICE_HOSTNAME inkyshot
