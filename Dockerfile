FROM python:3.11

RUN apt-get update && apt-get install -y \
    build-essential \
    gdal-bin \
    libgdal-dev \
    proj-data \
    proj-bin \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal
ENV GDAL_VERSION=3.4.3
ENV GDAL_DATA=/usr/share/gdal/3.4
ENV PROJ_LIB=/usr/share/proj

RUN echo "Listing all folders in /usr:" && ls -l /usr | grep '^d'



RUN echo "Checking GDAL paths..." && \
    [ -d "$CPLUS_INCLUDE_PATH" ] || (echo "Missing $CPLUS_INCLUDE_PATH" >&2 && exit 1) && \
    [ -d "$C_INCLUDE_PATH" ] || (echo "Missing $C_INCLUDE_PATH" >&2 && exit 1) && \
    [ -d "$GDAL_DATA" ] || (echo "Missing $GDAL_DATA" >&2 && exit 1) && \
    [ -d "$PROJ_LIB" ] || (echo "Missing $PROJ_LIB" >&2 && exit 1)

WORKDIR /app
COPY . .

RUN pip install --upgrade pip setuptools wheel

# Install numpy first to avoid dependency issues
RUN pip install --no-cache-dir numpy==1.26.4

# Then install Flask and GDAL
RUN pip install --no-cache-dir Flask flask-cors
RUN pip install --no-cache-dir GDAL==3.4.3

CMD ["python", "server.py"]
