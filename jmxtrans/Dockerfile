ARG JMXTRANS_VERSION
FROM jmxtrans/jmxtrans

MAINTAINER LoyaltyOne

# JMXTRANS_ENV=aws|local
ENV JMXTRANS_ENV=local

# JMXTRANS_HOSTS=type1#host1:port1,host2:port2,host3:port3..|type2#host4:port4,host5:port5,...|...
# type=zookeeper|kafka|schema-registry|kafka-connect|kafka-rest
ENV JMXTRANS_HOSTS=zookeeper#zk1:8989,zk2:8989,zk3:8989

# Copy configuration templates and entrypoint script
COPY config/*.json /usr/local/share/config/
COPY bootstrap /usr/local/bin/

# Execute our bootstrap before jmxtrans' entry point before starting the container.
ENTRYPOINT ["/usr/local/bin/bootstrap", "/docker-entrypoint.sh"]
CMD ["start-with-jmx"]