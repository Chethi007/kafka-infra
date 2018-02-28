#!/bin/bash

result=
while [[ -z "${result}" ]]; do
  echo "Waiting for cassandra..."
  sleep 5
  result=$(cqlsh --ssl -e "SELECT uuid() FROM system.local;" 2>&1 | \
    grep -E "[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}")
done

echo ""
echo "Running db-schema.cql..."
cqlsh --ssl -f "/usr/local/share/db-schema.cql"

result=
while [[ -z "${result}" ]]; do
  echo "Waiting for zookeeper..."
  sleep 5
  timeout 2 /bin/bash -c 'echo ruok | nc zookeeper 2181'
  result=$?
done

echo ""
echo "Setting up topic..."
kafka-topics --zookeeper zookeeper:2181 --create --topic test-simple --replication-factor 1 --partitions 1
kafka-topics --zookeeper zookeeper:2181 --create --topic test-avro --replication-factor 1 --partitions 1

result=
while [[ ${result} != 0 ]]; do
  echo "Waiting for kafka-connect node connect-1..."
  sleep 5
  curl -XGET http://connect-1:8083/connectors >> /dev/null 2>&1
  result=$?
done

echo ""
echo "Setting up connectors..."
curl -XPUT -H "Content-Type: application/json" -d @/usr/local/share/cassandra-sink-connector-simple.json \
    http://connect-1:8083/connectors/cassandra-sink-connector-simple/config
echo ""
curl -XPUT -H "Content-Type: application/json" -d @/usr/local/share/cassandra-sink-connector-avro.json \
    http://connect-1:8083/connectors/cassandra-sink-connector-avro/config

echo ""
echo "Done"