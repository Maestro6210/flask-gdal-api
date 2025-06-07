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


RUN echo "Listing all folders in /usr/share:" && ls -l /usr/share | grep '^d'





WORKDIR /app
COPY . .

RUN pip install --upgrade pip setuptools wheel

# Install numpy first to avoid dependency issues
RUN pip install --no-cache-dir numpy==2.2.0

# Then install Flask and GDAL
RUN pip install --no-cache-dir Flask flask-cors
RUN pip install --no-cache-dir GDAL==3.4.3

CMD ["python", "server.py"]
