#!/usr/bin/env bash
helm install stable/rabbitmq --name rabbit-server -f rabbit-values.yaml
