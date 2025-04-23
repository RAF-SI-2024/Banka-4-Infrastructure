#!/bin/bash
# Package and build graphs
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

set -eux

helm dependency build backend

fail=
helm lint backend || fail=true
helm lint frontend || fail=true

if [[ ${fail} ]]; then
    echo lints failed
    exit 1
fi

helm package backend
helm package frontend

helm push backend-*.tgz oci://harbor.k8s.elab.rs/banka-4/helm
helm push frontend-*.tgz oci://harbor.k8s.elab.rs/banka-4/helm
