FROM docker.elastic.co/beats/filebeat:7.5.1
COPY filebeat.yml /usr/share/filebeat/filebeat.yml
COPY logstash-forwarder.crt /etc/certs/logstash-forwarder.crt
USER root
RUN chown root:filebeat /usr/share/filebeat/filebeat.yml
USER filebeat