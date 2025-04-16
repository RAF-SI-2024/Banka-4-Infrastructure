#!/usr/bin/env bash
# Generate required secrets inside the currently-active kubectl namespace
# Copyright (C) 2025  Arsen Arsenović <aarsenovic8422rn@raf.rs>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

: "${RELEASE_NAME:=banka-4}"

if ! kubectl get secret "${RELEASE_NAME}"-jwt-secret >/dev/null; then
    newkey="$(head --bytes $((256 / 8)) /dev/urandom | base64 -w0)"
    kubectl create secret \
	    generic "${RELEASE_NAME}"-jwt-secret \
	    --from-literal=key="${newkey}" \
	    -o yaml --dry-run=client \
	| kubectl apply -f -
fi

if ! kubectl get secret "${RELEASE_NAME}"-alphavantage >/dev/null; then
    read -p "AlphaVantage key? " av_key
    kubectl create secret \
	    generic "${RELEASE_NAME}"-alphavantage \
	    --from-literal=apikey="${av_key}" \
	    -o yaml --dry-run=client \
	| kubectl apply -f -
fi

if ! kubectl get secret "${RELEASE_NAME}"-mailer-configuration >/dev/null; then
    kubectl create secret \
	    generic "${RELEASE_NAME}"-mailer-configuration \
	    --from-env-file=email-secret.conf \
	    -o yaml --dry-run=client \
	| kubectl apply -f -
fi


if ! kubectl get secret "${RELEASE_NAME}"-exchange-office-config >/dev/null; then
    read -p "Exchange Rate API key? " er_key
    contents="\
# -*- python -*-
COMMISSION_RATE = 0.1
EXCHANGERATE_API_KEY = \"${er_key}\"
EXCHANGE_STORAGE_PATH = \"/data/exchanges.json\"
"
    kubectl create secret \
	    generic "${RELEASE_NAME}"-exchange-office-config \
	    --from-file=config=/dev/stdin <<<"${contents}" \
	    -o yaml --dry-run=client \
	| kubectl apply -f -
fi
