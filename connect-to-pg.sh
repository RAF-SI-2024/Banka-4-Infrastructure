#!/bin/sh
PGPASSWORD="$(kubectl get secret banka-4-pguser-"$(whoami)" -o jsonpath='{.data.password}' | base64 -d)"
export PGPASSWORD
kubectl port-forward pod/"$(kubectl get pods --output=json -l postgres-operator.crunchydata.com/role=master | jq -r .items[0].metadata.name)" 15432:5432 &
sleep 1
psql -p 15432 -d bank-service -h localhost "$@"
status="$?"
trap 'kill %1' EXIT
exit "${status}"
