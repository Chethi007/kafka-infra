# Kafka Connect

A docker image based on the Confluent Platform docker images

# Build images

```bash
pushd cassandra
docker build . -t loyaltyone/cassandra:test
popd

pushd configurator
docker build . -t loyaltyone/configurator:test
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

# Test Kafka Connect API

For connect-1 container use port 8083 and for connect-2 container use
port 8084.

You should be able to access the REST API on both containers and get the
same response.

## List connector plugins
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

## List active connectors
```bash
curl -s localhost:8083/connectors | jq
```
```json
[
  "cassandra-sink-connector"
]
```

## Show configuration of `cassandra-sink-connector`
```bash
curl -s localhost:8083/connectors/cassandra-sink-connector | jq
```
```json
{
  "name": "cassandra-sink-connector",
  "config": {
    "connector.class": "com.datamountaineer.streamreactor.connect.cassandra.sink.CassandraSinkConnector",
    "connect.cassandra.consistency.level": "ONE",
    "connect.cassandra.key.space": "targetkeyspace",
    "tasks.max": "10",
    "topics": "test",
    "connect.cassandra.kcql": "INSERT INTO target SELECT * FROM test",
    "connect.cassandra.password": "cassandra",
    "connect.progress.enabled": "true",
    "connect.cassandra.username": "cassandra",
    "connect.cassandra.contact.points": "cassandra",
    "connect.cassandra.port": "9042",
    "name": "cassandra-sink-connector",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter": "org.apache.kafka.connect.storage.StringConverter"
  },
  "tasks": [
    {
      "connector": "cassandra-sink-connector",
      "task": 0
    },
    {
      "connector": "cassandra-sink-connector",
      "task": 1
    },
    {
      "connector": "cassandra-sink-connector",
      "task": 2
    },
    {
      "connector": "cassandra-sink-connector",
      "task": 3
    },
    {
      "connector": "cassandra-sink-connector",
      "task": 4
    },
    {
      "connector": "cassandra-sink-connector",
      "task": 5
    },
    {
      "connector": "cassandra-sink-connector",
      "task": 6
    },
    {
      "connector": "cassandra-sink-connector",
      "task": 7
    },
    {
      "connector": "cassandra-sink-connector",
      "task": 8
    },
    {
      "connector": "cassandra-sink-connector",
      "task": 9
    }
  ],
  "type": "sink"
}
