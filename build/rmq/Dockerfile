FROM rabbitmq:3
RUN apt update && apt install -y iputils-ping curl
RUN rabbitmq-plugins enable --offline rabbitmq_management
EXPOSE 15671 15672
