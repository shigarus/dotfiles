#!/usr/bin sh
# If docker service fails with `overlay2.override_kernel_ check: overlay2`
jq 'del(."storage-opts")' /etc/docker/daemon.json > /tmp/daemon.json && sudo mv /tmp/daemon.json /etc/docker/daemon.json
