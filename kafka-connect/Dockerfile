FROM confluentinc/cp-kafka-connect

ENV CONNECT_PLUGIN_PATH=/usr/local/share/kafka/plugins

ENV CONNECT_CONFIG_STORAGE_TOPIC=kafka-connect-configs
ENV CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=1

ENV CONNECT_OFFSET_FLUSH_INTERVAL_MS=10000
ENV CONNECT_OFFSET_STORAGE_TOPIC=kafka-connect-offsets
ENV CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=1

ENV CONNECT_STATUS_STORAGE_TOPIC=kafka-connect-status
ENV CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=1

ENV CONNECT_KEY_CONVERTER=org.apache.kafka.connect.json.JsonConverter
ENV CONNECT_VALUE_CONVERTER=org.apache.kafka.connect.json.JsonConverter
ENV CONNECT_INTERNAL_KEY_CONVERTER=org.apache.kafka.connect.json.JsonConverter
ENV CONNECT_INTERNAL_VALUE_CONVERTER=org.apache.kafka.connect.json.JsonConverter

ADD setup-plugins.sh /usr/local/bin/setup-plugins.sh

RUN setup-plugins.sh