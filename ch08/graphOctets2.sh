#!/bin/sh
# filename: /opt/OV/local/scripts/graphOctets2
# syntax: graphOctets <hostname>
/opt/OV/bin/xnmgraph -c public -title Bits_In_n_Out -mib \
".1.3.6.1.4.1.9.2.2.1.1.6:::::.1.3.6.1.2.1.2.2.1.2:::,\
.1.3.6.1.4.1.9.2.2.1.1.8:::::.1.3.6.1.2.1.2.2.1.2:::" $1

