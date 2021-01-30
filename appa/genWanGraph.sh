#!/bin/sh

/opt/OV/bin/xnmgraph -monochrome -c public -poll 5 -title \
Cisco_Private_Local_Mib -mib \
".1.3.6.1.4.1.9.2.2.1.1.6:CiscoRouter1a:4:::.1.3.6.1.2.1.2.2.1.2:::,\
.1.3.6.1.4.1.9.2.2.1.1.8:CiscoRouter1a:4:::.1.3.6.1.2.1.2.2.1.2:::" \
CiscoRouter1a &

/opt/OV/bin/xnmgraph -monochrome -c public -poll 5 -title Ifutil_Formula \
-mib "If%util:CiscoRouter1a:4:::.1.3.6.1.2.1.2.2.1.2:::" CiscoRouter1a &
/opt/OV/bin/xnmgraph -monochrome -c public -poll 5 -title \
WANIfRecvUtil_Formula -mib \
"WANIf%RecvUtil:CiscoRouter1a:4:::.1.3.6.1.2.1.2.2.1.2:::" CiscoRouter1a &

/opt/OV/bin/xnmgraph -monochrome -c public -poll 5 -title
WANIfSendUtil_Formula -mib \
"WANIf%SendUtil:CiscoRouter1a:4:::.1.3.6.1.2.1.2.2.1.2:::" CiscoRouter1a &

/opt/OV/bin/xnmgraph -monochrome -c public -poll 5 -title ifInOctets -mib \
".1.3.6.1.2.1.2.2.1.10:CiscoRouter1a:4:::.1.3.6.1.2.1.2.2.1.2:::" \
CiscoRouter1a &

/opt/OV/bin/xnmgraph -monochrome -c public -poll 5 -title ifOutOctets -mib \
".1.3.6.1.2.1.2.2.1.16:CiscoRouter1a:4:::.1.3.6.1.2.1.2.2.1.2:::" \
CiscoRouter1a &

