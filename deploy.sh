#!/usr/bin/env bash
helm upgrade \
     --namespace="pgo" --create-namespace \
     --atomic --install pgo \
     oci://registry.developers.crunchydata.com/crunchydata/pgo
helm upgrade \
     --namespace="banka-4" \
     --create-namespace \
     --atomic --install banka-4-rabbitmq \
     oci://registry-1.docker.io/bitnamicharts/rabbitmq
