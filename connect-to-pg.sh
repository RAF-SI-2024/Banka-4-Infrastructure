#!/bin/sh
PGPASSWORD="$(kubectl get secret banka-4-pguser-"$(whoami)" -o jsonpath='{.data.password}' | base64 -d)"
export PGPASSWORD
kubectl port-forward pod/banka-4-instance1-2dzb-0 15432:5432 &
sleep 1
psql -p 15432 -d user-service -h localhost "$@"
status="$?"
trap 'kill %1' EXIT
exit "${status}"
