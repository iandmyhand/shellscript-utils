#!/bin/sh
PRIVATE_IP="$(curl http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null)"
IP_LAST_HALF="$(echo $PRIVATE_IP | cut -d'.' -f 3,4)"
echo $IP_LAST_HALF

