#!/bin/bash

mkdir -p /run/sshd

cat /cont/title
echo -e

echo "Server is running..."
exec /usr/sbin/sshd -D