# Kafka Connect

A docker image based on the Confluent Platform docker images

# Prerequisites

## Cassandra SSL

The [Cassandra AWS](https://github.com/LoyaltyOne/cassandra-aws) repo
has tools to generate SSL certificates.

Generate the certificates:
```bash
git clone https://github.com/LoyaltyOne/cassandra-aws.git
cd cassandra-aws
./truststore-setup cassandra cassandra
```

Switch back to `kafka-infra` path and copy certificates, keystore and truststore:
```bash
cd path-to/kafka-infra
mkdir -p cassandra/config/.cassandra
cp /path-to/cassandra-aws/cluster-ca-certificate.pem cassandra/config/.cassandra/

mkdir -p cassandra/config/etc/cassandra/conf/certs
cp /path-to/cassandra-aws/cassandra-config/conf/certs/* cassandra/config/etc/cassandra/conf/certs/

mkdir -p configurator/config/.cassandra
cp /path-to/cassandra-aws/cluster-ca-certificate.pem configurator/config/.cassandra/

mkdir -p kafka-connect/config/certs
cp /path-to/cassandra-aws/cassandra-config/conf/certs/* kafka-connect/config/certs/
```

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

You should be able to access the REST API on both containers and get the
same response.

## List connector plugins
```bash
docker exec -it connect-1 curl -s localhost:8083/connector-plugins | jq
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
docker exec -it connect-1 curl -s localhost:8083/connectors | jq
```
```json
[
  "cassandra-sink-connector-simple",
  "cassandra-sink-connector-avro"
]
```

## Show configuration of `cassandra-sink-connector-simple`
```bash
docker exec -it connect-1 curl -s localhost:8083/connectors/cassandra-sink-connector-simple | jq
```
```json
{
  "name": "cassandra-sink-connector-simple",
  "config": {
    "name": "cassandra-sink-connector-simple",
    "connector.class": "com.datamountaineer.streamreactor.connect.cassandra.sink.CassandraSinkConnector",
    "tasks.max": "10",
    "topics": "test-no-schema",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable": "false",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "false",
    "connect.cassandra.contact.points": "cassandra",
    "connect.cassandra.port": "9042",
    "connect.cassandra.key.space": "targetkeyspace",
    "connect.cassandra.username": "cassandra",
    "connect.cassandra.password": "cassandra",
    "connect.cassandra.kcql": "INSERT INTO SimpleTable SELECT * FROM test-simple",
    "connect.cassandra.consistency.level": "ONE",
    "connect.progress.enabled": "true"
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

## Test the connectors

### cassandra-sink-connector-simple

Produce a couple of messages:
```bash
docker exec -it kafka kafka-console-producer --broker-list kafka:9092 --topic test-simple
```

Type in the following lines and then CTRL+C to stop the producer:
```
{"id": "foo"}
{"id": "bar"}
```

Check that the new messages are in the table:
```bash
docker exec -it cassandra cqlsh --ssl -e 'select * from TestKeySpace.SimpleTable;'
```
```
 id
----
 bar
 foo

(2 rows)
```

### cassandra-sink-connector-avro

For some reason, the console producer for AVRO is not available in kafka
container. You have to execute this on the `schema-registry` container.

```bash
docker exec -it schema-registry kafka-avro-console-producer --broker-list kafka:9092 --property value.schema='{"type": "record", "name": "simple_avro_record", "fields": [{"name": "id", "type": "string"}]}' --topic test-avro
```

You'll see some INFO logs like this:
```
[2018-02-26 17:59:40,275] INFO ProducerConfig values:
        acks = 1
        batch.size = 16384
        bootstrap.servers = [kafka:9092]
        ...
        ...
        ...
        ...
        transactional.id = null
        value.serializer = class org.apache.kafka.common.serialization.ByteArraySerializer
 (org.apache.kafka.clients.producer.ProducerConfig)
[2018-02-26 17:59:40,362] INFO Kafka version : 1.0.0-cp1 (org.apache.kafka.common.utils.AppInfoParser)
[2018-02-26 17:59:40,362] INFO Kafka commitId : ec61c5e93da662df (org.apache.kafka.common.utils.AppInfoParser)
```

Type in the following lines and then CTRL+C to stop the producer:
```
{"id": "baz"}
{"id": "dob"}
```

Check that the new messages are in the table:
```bash
docker exec -it cassandra cqlsh --ssl -e 'select * from TestKeySpace.SimpleTable;'
```
```
 id
----
 foo
 bar
 baz
 dob

(4 rows)
```