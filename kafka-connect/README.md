# Kafka Connect

A docker image based off the Confluent Platform

# Build

```bash
docker build .
```

# Run

```bash
HOST_IP=x.x.x.x
IMAGE_ID=xxxxxxx
docker run -d \
  -e "CONNECT_BOOTSTRAP_SERVERS=${HOST_IP}:9092" \
  -e "CONNECT_ZOOKEEPER_CONNECT=${HOST_IP}:2181" \
  -e "CONNECT_REST_ADVERTISED_HOST_NAME=connect-1" \
  -e "CONNECT_REST_PORT=8083" \
  -e "CONNECT_GROUP_ID=kafka-connect-group" \
  -p 8083:8083 \
  -it $IMAGE_ID
```

# Tag and Publish

TODO
