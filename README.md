# TODO

- pipeline (update canary, test, update live)
- investigate nested stacks (**DONE**)
- ssl self signed certs? (can we use a cert manager?)
- align configurator and target-domain (functional overlap)
- drop .sh on command files
- use shell check for linting scripts
- link to docker mirror docs

# Kafka Connect

A docker image based on the Confluent Platform docker images

## Prerequisites

### Cassandra SSL

The [Cassandra AWS](https://github.com/LoyaltyOne/cassandra-aws) repo
has tools to generate SSL certificates.

Get the `cassandra-aws` repo:
```bash
git clone https://github.com/LoyaltyOne/cassandra-aws.git
```

Switch to `kafka-infra` path to generate the certificates and copy them
to appropriate locations:
```bash
cd path-to/kafka-infra

path-to/cassandra-aws/truststore-setup cassandra cassandra

mkdir -p cassandra/config/.cassandra
cp cluster-ca-certificate.pem cassandra/config/.cassandra/

mkdir -p cassandra/config/etc/cassandra/conf/certs
cp cassandra-config/conf/certs/* cassandra/config/etc/cassandra/conf/certs/
```

__NOTE:__ Ideally, a different keystore/truststore should be created for
clients using different passwords. The same CA certificate can be used to
sign the client certificates and the truststore can contain the CA
certificate.

For now, we'll use the same keystore/truststore for the local
environment.
```bash
mkdir -p configurator/config/.cassandra
cp cluster-ca-certificate.pem configurator/config/.cassandra/

mkdir -p kafka-connect/config/certs
cp cassandra-config/conf/certs/* kafka-connect/config/certs/
```

Cleanup:
```bash
rm -rf cluster-ca-certificate.pem cassandra-config
```

## Running locally

Make sure cassandra db directory exists:

```bash
mkdir -p db
```

```bash
docker-compose up -d
```

## Test Kafka Connect API

You should be able to access the REST API on both containers and get the
same response.

### List connector plugins
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

### List active connectors
```bash
docker exec -it connect-1 curl -s localhost:8083/connectors | jq
```
```json
[
  "cassandra-sink-connector-simple",
  "cassandra-sink-connector-avro"
]
```

### Show configuration of `cassandra-sink-connector-simple`
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
```

### Test the connectors

#### cassandra-sink-connector-simple

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

#### cassandra-sink-connector-avro

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

# Kafka Rest Proxy

## Deploy

Parameters File __dev.params.json_:
```json
AWS_REGION=us-east-1
APP_PORT=8082
KAFKA_REST_BOOTSTRAP_SERVERS=change_me
KAFKA_REST_ZOOKEEPER_CONNECT=change_me
KAFKA_REST_SCHEMA_REGISTRY_URL=change_me
```
Environment File __dev.env__:
```
{
    "ClusterStackName": "change_me",
    "Priority": "104",
    "KinesisStackName": "change_me",
    "AppMaxCount": "1",
    "AppMinCount": "1",
    "Cpu": "1024",
    "Memory": "1024",
    "HostedZoneStackName": "change_me",
    "TrustedCertsBucket": "change_me"
}
```
Tags File __dev.tags.json:
```json
{
  "Team": "change_me",
  "Project": "change_me",
  "Environment": "dev",
  "Component": "kafka-rest"
}
```

```bash
cd kafka-rest

ecs-service deploy dev-cp-kafka-rest 0.1-beta service.json \
    ../../kafka-infra-config/kafka-rest/dev.params.json \
    --env-file ../../kafka-infra-config/kafka-rest/dev.env \
    --tag-file ../../kafka-infra-config/kafka-rest/dev.tags.json \
    --region us-east-1 \
    --profile assumed_role
```

## Testing REST Proxy

Change the host name based on your hosted zone:
```bash
KAFKA_REST_URL=https://cp-kafka-rest.change_me
```

## Monitoring REST Proxy

The Prometheus JMX Exporter agent is used to expose metrics via HTTP on
port 9404. The metrics will need to be scraped by a Prometheus server.

```bash
docker exec -it kafka-rest-1 curl localhost:9404
```

### JSON Messages

#### Produce

```bash
curl -X POST \
    -H "Content-Type: application/vnd.kafka.json.v2+json" \
    -H "Accept: application/vnd.kafka.v2+json" \
    --data '{"records":[{"value":{"foo":"bar"}}]}' \
    $KAFKA_REST_URL/topics/test-simple
```

#### Consume

```bash
curl -X POST \
    -H "Content-Type: application/vnd.kafka.v2+json" \
    --data '{"name": "my_consumer_instance", "format": "json", "auto.offset.reset": "earliest"}' \
    $KAFKA_REST_URL/consumers/my_json_consumer

curl -X POST \
    -H "Content-Type: application/vnd.kafka.v2+json" \
    --data '{"topics":["test-simple"]}' \
    $KAFKA_REST_URL/consumers/my_json_consumer/instances/my_consumer_instance/subscription

curl -X GET \
    -H "Accept: application/vnd.kafka.json.v2+json" \
    $KAFKA_REST_URL/consumers/my_json_consumer/instances/my_consumer_instance/records

curl -X DELETE \
    -H "Content-Type: application/vnd.kafka.v2+json" \
    $KAFKA_REST_URL/consumers/my_json_consumer/instances/my_consumer_instance
```

### Avro Messages with Embedded Schema

#### Produce

```bash
curl -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" \
    -H "Accept: application/vnd.kafka.v2+json" \
    --data '{"value_schema": "{\"type\": \"record\", \"name\": \"User\", \"fields\": [{\"name\": \"name\", \"type\": \"string\"}]}", "records": [{"value": {"name": "testUser"}}]}' \
    $KAFKA_REST_URL/topics/avrotest
```

#### Consume

```bash
curl -X POST \
    -H "Content-Type: application/vnd.kafka.v2+json" \
    --data '{"name": "my_consumer_instance", "format": "avro", "auto.offset.reset": "earliest"}' \
    $KAFKA_REST_URL/consumers/my_avro_consumer

curl -X POST \
    -H "Content-Type: application/vnd.kafka.v2+json" \
    --data '{"topics":["avrotest"]}' \
    $KAFKA_REST_URL/consumers/my_avro_consumer/instances/my_consumer_instance/subscription

curl -X GET \
    -H "Accept: application/vnd.kafka.avro.v2+json" \
    $KAFKA_REST_URL/consumers/my_avro_consumer/instances/my_consumer_instance/records
```

### Avro Messages using Schema Registry

#### Produce

```bash
curl -X POST \
    -H "Content-Type: application/vnd.kafka.avro.v2+json" \
    -H "Accept: application/vnd.kafka.v2+json" \
    --data '{"key_schema": "{\"name\":\"user_id\"  ,\"type\": \"int\"}", "value_schema": "{\"type\": \"record\", \"name\": \"User\", \"fields\": [{\"name\": \"name\", \"type\": \"string\"}]}", "records": [{"key" : 1 , "value": {"name": "testUser"}}]}' \
    $KAFKA_REST_URL/topics/avrotest2
```

#### Consume

```bash
curl -X POST \
    -H "Content-Type: application/vnd.kafka.v2+json" \
    --data '{"name": "my_consumer_instance", "format": "avro", "auto.offset.reset": "earliest"}' \
    $KAFKA_REST_URL/consumers/my_avro_consumer

curl -X POST \
    -H "Content-Type: application/vnd.kafka.v2+json" \
    --data '{"topics":["avrotest2"]}' \
    $KAFKA_REST_URL/consumers/my_avro_consumer/instances/my_consumer_instance/subscription

curl -X GET \
    -H "Accept: application/vnd.kafka.avro.v2+json" \
    $KAFKA_REST_URL/consumers/my_avro_consumer/instances/my_consumer_instance/records

curl -X DELETE \
    -H "Content-Type: application/vnd.kafka.v2+json" \
    $KAFKA_REST_URL/consumers/my_avro_consumer/instances/my_consumer_instance
```
