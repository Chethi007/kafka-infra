FROM prom/prometheus:v2.2.1

MAINTAINER LoyaltyOne

COPY bootstrap /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/bootstrap", "/bin/prometheus"]

CMD [ "--config.file=/etc/prometheus/prometheus.yml", \
      "--storage.tsdb.path=/prometheus", \
      "--storage.tsdb.min-block-duration=30m", \
      "--storage.tsdb.max-block-duration=1d", \
      "--web.console.libraries=/usr/share/prometheus/console_libraries", \
      "--web.console.templates=/usr/share/prometheus/consoles" ]