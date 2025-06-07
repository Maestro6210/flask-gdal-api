FROM python:3.11-slim

# Install system packages needed to build GDAL
RUN apt-get update && apt-get install -y \
    gdal-bin \
    libgdal-dev \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set GDAL environment variables for pip to find headers
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

# Install numpy first, then GDAL and others
RUN pip install --no-cache-dir --upgrade pip setuptools wheel
RUN pip install --no-cache-dir numpy
RUN pip install --no-cache-dir Flask flask-cors GDAL==3.4.3

# Copy your app and rest of Dockerfile...
COPY . /app
WORKDIR /app

CMD ["python", "server.py"]
