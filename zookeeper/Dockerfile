FROM confluentinc/cp-zookeeper:4.0.0-3

MAINTAINER LoyaltyOne

COPY bootstrap /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/bootstrap"]
CMD ["/etc/confluent/docker/run"]