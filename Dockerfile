FROM python:3.11

RUN apt-get update && apt-get install -y \
    gdal-bin \
    libgdal-dev \
    proj-data \
    proj-bin \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal
ENV GDAL_VERSION=3.11.0


RUN echo "Listing all folders in /usr/share:" && ls -l /usr/share | grep '^d'

RUN pip install --upgrade pip setuptools wheel

RUN pip install --no-cache-dir numpy

# Then install Flask and GDAL
RUN pip install --no-cache-dir Flask flask-cors
RUN pip install --no-cache-dir GDAL==3.11.0

COPY . /app
WORKDIR /app
CMD ["python", "server.py"]
