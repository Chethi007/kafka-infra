CREATE KEYSPACE TestKeySpace
  WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'}
  AND durable_writes = true;

CREATE TABLE TestKeySpace.SimpleTable (
  id text PRIMARY KEY
);
