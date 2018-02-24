FROM confluentinc/cp-kafka

RUN pip install --upgrade pip && pip install cqlsh

ADD setup.sh /usr/local/bin/
ADD db-schema.cql /usr/local/share/
ADD cassandra-sink-connector.json /usr/local/share/

CMD /usr/local/bin/setup.sh
