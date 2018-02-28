FROM confluentinc/cp-kafka-connect:4.0.0-3

MAINTAINER LoyaltyOne

COPY bootstrap setup-plugins.sh s3-cp.sh /usr/local/bin/
#TODO: This is for local. Should remove
COPY config/certs /root/certs

RUN setup-plugins.sh

ENTRYPOINT ["/usr/local/bin/bootstrap", "/usr/local/bin/s3-cp", "/etc/confluent/docker/run"]