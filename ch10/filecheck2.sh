#!/bin/sh
# FileName: /opt/local/shell_scripts/filecheck2.sh
if [ -f $1 ]; then
   ls -la $1
   exit 0
fi
exit 1

