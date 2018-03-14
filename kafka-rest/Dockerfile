FROM confluentinc/cp-kafka-rest:4.0.0-3

MAINTAINER LoyaltyOne

COPY bootstrap /usr/local/bin/
COPY jmx_prometheus_javaagent-0.2.0.jar /usr/local/share/
COPY metrics.yml /usr/local/share/

ENTRYPOINT ["/usr/local/bin/bootstrap"]
CMD ["/etc/confluent/docker/run"]