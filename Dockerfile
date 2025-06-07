FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    python3-dev \
    gdal-bin \
    libgdal-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*


RUN pip install --no-cache-dir numpy

RUN pip install --no-cache-dir Flask flask-cors GDAL==3.4.3

COPY . /app
WORKDIR /app

CMD ["python", "server.py"]
