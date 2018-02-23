FROM python:2.7-alpine

RUN pip install cqlsh

ADD setup.sh /usr/local/bin/setup.sh
ADD db-schema.cql /usr/local/share/db-schema.cql

CMD /usr/local/bin/setup.sh
