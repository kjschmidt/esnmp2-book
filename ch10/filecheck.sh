#!/bin/sh
# FileName: /opt/local/shell_scripts/filecheck.sh
if [ -f $1 ]; then
   exit 0
fi
exit 1

