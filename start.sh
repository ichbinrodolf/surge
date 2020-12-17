#!/bin/bash
chown app:app /dev/stdout
mkdir -p /data/Downloads/surge_downloads
chown -R app:app /data
exec gosu app supervisord
