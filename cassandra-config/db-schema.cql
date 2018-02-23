CREATE KEYSPACE targetkeyspace
    WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '3'}
    AND durable_writes = true;

CREATE TABLE targetkeyspace.target (
    id text PRIMARY KEY,
    createdon timestamp,
    displaydate timestamp,
    enddate timestamp,
    lastmodifiedon timestamp,
    memberid varint,
    offer text,
    offerid text,
    partnerid text,
    startdate timestamp,
    state text
);
