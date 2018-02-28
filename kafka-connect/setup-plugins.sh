#!/bin/bash

# Install AWS CLI
pip install --upgrade pip
pip install awscli

# Setup some vars
src=https://github.com/Landoop/stream-reactor/releases/download/1.0.0/kafka-connect-cassandra-1.0.0-1.0.0-all.tar.gz
filename=${src##*/}
dest=/usr/local/share/kafka/plugins

# Create destination folder in case its missing
mkdir -p ${dest}
# Create destination folder for certs
if [ -n "$S3_CP_LOCAL_PATH" ]; then
	mkdir -p ${S3_CP_LOCAL_PATH}
fi

# Download the connectors
echo "Downloading Kafka Connect Plugin ${src}..."
wget -q ${src} -O ${dest}/${filename}

# Install the connectors
echo "Installing Kafka Connect Plugin..."
cd ${dest}
tar xvzf ${filename}
rm -f ${filename}