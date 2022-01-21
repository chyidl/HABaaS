#!/bin/sh
if [ -z "`pidof nginx`" ]; then
    exit 1
fi
