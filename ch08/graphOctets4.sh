#!/bin/sh
# filename: /opt/OV/local/scripts/graphOctets4
# syntax: graphOctets <hostname>
/opt/OV/bin/xnmgraph -c public -title Internet_Traffic_In_K -poll 68 -mib \
".1.3.6.1.4.1.9.2.2.1.1.6:Incoming_Traffic::::.1.3.6.1.2.1.2.2.1.2::.001:,\
.1.3.6.1.4.1.9.2.2.1.1.8:Outgoing_Traffic::::.1.3.6.1.2.1.2.2.1.2::.001:" \
$1

