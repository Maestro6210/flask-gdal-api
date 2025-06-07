FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    gdal-bin \
    libgdal-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal
ENV GDAL_VERSION=3.4.3
ENV GDAL_DATA=/usr/share/gdal/3.4
ENV PROJ_LIB=/usr/share/proj

RUN echo "Checking GDAL paths..." && \
    ls -ld $CPLUS_INCLUDE_PATH || echo "Missing $CPLUS_INCLUDE_PATH" && \
    ls -ld $C_INCLUDE_PATH || echo "Missing $C_INCLUDE_PATH" && \
    ls -ld $GDAL_DATA || echo "Missing $GDAL_DATA" && \
    ls -ld $PROJ_LIB || echo "Missing $PROJ_LIB"

WORKDIR /app
COPY . .

RUN pip install --upgrade pip setuptools wheel

# Install numpy first to avoid dependency issues
RUN pip install --no-cache-dir numpy

# Then install GDAL and other deps
RUN pip install --no-cache-dir Flask flask-cors
RUN pip install --no-cache-dir GDAL==3.4.3

CMD ["python", "server.py"]
