#!/bin/bash

result=
while [[ -z "${result}" ]]; do
  echo "Waiting for cassandra..."
  sleep 5
  result=$(cqlsh -u cassandra -p cassandra --cqlversion=3.4.4 -e "SELECT uuid() FROM system.local;" cassandra 2>&1 | grep -E "[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}")
done

echo ""
echo "Running db-schema.cql..."
cqlsh -u cassandra -p cassandra -f "/usr/local/share/db-schema.cql" --cqlversion=3.4.4 cassandra

result=
while [[ -z "${result}" ]]; do
  echo "Waiting for zookeeper..."
  sleep 5
  timeout 2 /bin/bash -c 'echo ruok | nc zookeeper 2181'
  result=$?
done

echo ""
echo "Setting up topic..."
kafka-topics --zookeeper zookeeper:2181 --create --topic test --replication-factor 1 --partitions 1

result=
while [[ ${result} != 0 ]]; do
  echo "Waiting for kafka-connect node connect-1..."
  sleep 5
  curl -XGET http://connect-1:8083/connectors >> /dev/null 2>&1
  result=$?
done

echo ""
echo "Setting up connectors..."
curl -XPUT -H "Content-Type: application/json" -d @/usr/local/share/cassandra-sink-connector.json http://connect-1:8083/connectors/cassandra-sink-connector/config

echo ""
echo "Done"