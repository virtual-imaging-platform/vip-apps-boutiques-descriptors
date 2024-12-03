FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# Create app directory
RUN mkdir /app

# Install program files from a git tag ...
RUN cd /app && git clone --depth=1 --branch=main https://github.com/virtual-imaging-platform/vip-apps-boutiques-descriptors /tmp/gitrepo && (cd /tmp/gitrepo/packaging-example && mv example.py /app) && rm -rf /tmp/gitrepo

# ... or directly copy program files into the container
#COPY ./example.py /app/example.py

# Install app dependencies
#RUN cd /app && pip install --no-cache-dir -r requirements.txt

