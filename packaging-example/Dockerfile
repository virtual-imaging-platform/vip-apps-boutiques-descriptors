FROM python:3.10-slim

# Set defaults for build arguments
ARG USER_UID=1000
ARG USER_GID=1000

# Create non-root user and group, and prevent login
RUN groupadd -g $USER_GID vip && \
    useradd -r -u $USER_GID -g vip -d /home/vip -m -s /usr/sbin/nologin vip

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# Install program files from a git tag ...
RUN git clone --depth=1 --branch=main https://github.com/virtual-imaging-platform/vip-apps-boutiques-descriptors /tmp/gitrepo && (cd /tmp/gitrepo/packaging-example && mv example.py /home/vip/) && rm -rf /tmp/gitrepo

# ... or directly copy program files into the container
#COPY ./example.py /home/vip/example.py

# Install app dependencies
#USER vip
#WORKDIR /home/vip
#RUN pip install --no-cache-dir -r requirements.txt

