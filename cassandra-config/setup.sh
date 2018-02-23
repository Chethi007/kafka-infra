#!/bin/sh

result=
while test -z "$result"; do
  echo "Waiting for cassandra..."
  sleep 5
  result=$(cqlsh -u cassandra -p cassandra --cqlversion=3.4.4 -e "SELECT uuid() FROM system.local;" cassandra 2>&1 | grep -E "[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}")
done

echo "Running db-schema.cql..."
cqlsh -u cassandra -p cassandra -f "/usr/local/share/db-schema.cql" --cqlversion=3.4.4 cassandra

echo "Done"