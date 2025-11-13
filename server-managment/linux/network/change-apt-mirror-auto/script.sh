#!/bin/bash

PREFERRED_MIRROR="mirrord.cipfpbatoi.lan"

if ping -c 1 -W "$PREFERRED_MIRROR" > /dev/null 2>&1; then
    echo "deb http://$PREFERRED_MIRROR/debian stable main contrib non-free\ndeb-src http://$PREFERRED_MIRROR/debian stable main contrib non-free" > /etc/apt/sources.list
else
    netselect-apt > /etc/apt/sources.list
fi
