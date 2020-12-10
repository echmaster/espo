#!/usr/bin/env bash
cd ./comc
QUEUE=$1
./yii rabbitmq/consume "$QUEUE"
# ./yii rabbitmq/consume subscribe-consumer