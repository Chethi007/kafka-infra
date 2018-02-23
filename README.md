# Kafka Connect

A docker image based on the Confluent Platform docker images

# Build images

```bash
pushd cassandra
docker build . -t loyaltyone/cassandra:test
popd

pushd cassandra-config
docker build . -t loyaltyone/cassandra-config:test
popd

pushd kafka-connect
docker build . -t loyaltyone/kafka-connect:test
popd
```

# Running locally

Make sure cassandra db directory exists:

```bash
mkdir -p db
```

```bash
docker-compose up -d
```

Test the Kafka Connect API on connect-1 node:

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


Test the Kafka Connect API on connect-2 node:
```bash
curl -s localhost:8084/connector-plugins | jq
```
You should be able to access the REST API on both containers and get the
same response as above.


