FROM python:3.10-slim

# Set defaults for build arguments
ARG USER_UID=1000
ARG USER_GID=1000

# Create non-root user and group, and prevent login
RUN groupadd -g $USER_GID vip && \
    useradd -r -u $USER_GID -g vip -d /home/vip -m -s /usr/sbin/nologin vip

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    rm -rf /var/lib/apt/lists/*

# Copy app program files into the container
COPY ./example.py /home/vip/example.py

# Install app dependencies
# RUN python -m venv /home/vip/venv && \
#    source /home/vip/venv/bin/activate && \
#    cd /home/vip/example && \
#    pip install

# Set executable permissions for non-root user
# RUN chown -R root:root /home/vip/example && \
#    chmod 755 /home/vip/example

