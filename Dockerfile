FROM python:3.11

# Install dependencies needed to build GDAL
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    python3-dev \
    libsqlite3-dev \
    libgeos-dev \
    libproj-dev \
    proj-data \
    proj-bin \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV GDAL_VERSION=3.5.0

RUN pip install --force-reinstall GDAL==3.5.0
rm -rf /usr/local/bin/gdal* /usr/local/lib/libgdal* /usr/local/include/gdal /usr/local/share/gdal
ldconfig
RUN pip install --force-reinstall numpy



# Download and build GDAL from source
RUN wget https://github.com/OSGeo/gdal/releases/download/v3.5.0/gdal-3.5.0.tar.gz \
    && tar -xzf gdal-${GDAL_VERSION}.tar.gz \
    && cd gdal-${GDAL_VERSION} \
    && ./configure --with-python=python3 \
    && make -j$(nproc) \
    && make install \
    && ldconfig \
    && cd .. \
    && rm -rf gdal-${GDAL_VERSION} gdal-${GDAL_VERSION}.tar.gz

# Set include paths for GDAL headers for pip install
ENV CPLUS_INCLUDE_PATH=/usr/local/include
ENV C_INCLUDE_PATH=/usr/local/include

RUN pip install --upgrade pip setuptools wheel


# Install Python packages, including GDAL Python bindings matching system GDAL
RUN pip install --no-cache-dir GDAL==3.5.0 Flask flask-cors


COPY . /app
WORKDIR /app

CMD ["python", "server.py"]


