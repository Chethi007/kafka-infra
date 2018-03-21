ARG JMXTRANS_VERSION
FROM jmxtrans/jmxtrans

MAINTAINER LoyaltyOne

# JMXTRANS_ENV=aws|local
ENV JMXTRANS_ENV=local

# JMXTRANS_HOSTS
# local: zookeeper
# aws: host1,host2,host3
ENV JMXTRANS_HOSTS=zookeeper

RUN apt-get update && apt-get -y install jq

COPY config/*.json /usr/local/share/config/
COPY bootstrap /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/bootstrap", "/docker-entrypoint.sh"]
CMD ["start-with-jmx"]