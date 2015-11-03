FROM python:2.7-slim

ENV INFLUXDB_HOST influxdb
ENV INFLUXDB_PORT 8086
ENV INFLUXDB_USER root
ENV INFLUXDB_PASSWORD root
ENV INFLUXDB_NAME k8s

RUN apt-get update && apt-get install -y build-essential --no-install-recommends \
    && pip install locustio pyzmq influxdb \
    && pip install --upgrade influxdb \
    && apt-get purge -y --auto-remove build-essential
RUN ulimit -c -m -s -t unlimited
COPY scripts /scripts

ENTRYPOINT ["locust"]
