FROM confluentinc/cp-kafka-connect:4.0.0-3

MAINTAINER LoyaltyOne

COPY bootstrap /usr/local/bin/
COPY setup-plugins.sh /usr/local/bin/setup-plugins.sh
COPY config/certs /root/certs

RUN setup-plugins.sh

ENTRYPOINT ["/usr/local/bin/bootstrap"]
CMD ["/etc/confluent/docker/run"]