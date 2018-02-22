# Kafka Connect

A docker image based on the Confluent Platform docker images

# Build

```bash
docker build . -t loyaltyone/kafka-connect:test
```

# Run

Set the host IP assuming Kafka is running on the host:

```bash
HOST_IP=x.x.x.x
```

Run the container:
```bash
docker run -d \
  -e "CONNECT_BOOTSTRAP_SERVERS=${HOST_IP}:9092" \
  -e "CONNECT_ZOOKEEPER_CONNECT=${HOST_IP}:2181" \
  -e "CONNECT_REST_ADVERTISED_HOST_NAME=connect-1" \
  -e "CONNECT_REST_PORT=8083" \
  -e "CONNECT_GROUP_ID=kafka-connect-group" \
  -p 8083:8083 \
  -it loyaltyone/kafka-connect:test
```

You should be able to access the Kafka Connect REST API.

```bash
curl -s localhost:8083/connector-plugins | jq
```
```json [
  {
    "class": "com.datamountaineer.streamreactor.connect.cassandra.sink.CassandraSinkConnector",
    "type": "sink",
    "version": "1.0.0"
  },
  {
    "class": "com.datamountaineer.streamreactor.connect.cassandra.source.CassandraSourceConnector",
    "type": "source",
    "version": "1.0.0"
  },
  {
    "class": "org.apache.kafka.connect.file.FileStreamSinkConnector",
    "type": "sink",
    "version": "1.0.0-cp1"
  },
  {
    "class": "org.apache.kafka.connect.file.FileStreamSourceConnector",
    "type": "source",
    "version": "1.0.0-cp1"
  }
]
```

If using Docker Compose, it will launch Kafka/Zookeeper and run Kafka
Connect against them with bridged network.

```bash
docker-compose up -d
```

You should be able to access the REST API on both containers and get the
same response as above.

```bash
curl -s localhost:8083/connector-plugins | jq
```
```bash
curl -s localhost:8084/connector-plugins | jq
```

# Publish

TODO
