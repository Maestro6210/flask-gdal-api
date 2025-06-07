FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    gdal-bin \
    libgdal-dev \
    curl \
  && rm -rf /var/lib/apt/lists/*

ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal
ENV GDAL_VERSION=3.4.3

COPY requirements.txt .

# Install numpy first
RUN pip install --no-cache-dir numpy

# Then install other requirements except numpy (filter numpy out)
RUN pip install --no-cache-dir -r <(grep -v numpy requirements.txt)

COPY . /app
WORKDIR /app

CMD ["python", "server.py"]
