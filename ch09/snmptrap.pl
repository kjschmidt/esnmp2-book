#!/usr/local/bin/perl
# Filename: /opt/local/perl_scripts/snmptrap.pl
use SNMP_util "0.54";  # This will load the BER and SNMP_Session for us
snmptrap("public\@nms:162", ".1.3.6.1.4.1.2789", "sunserver1", 6, 1247, \
         ".1.3.6.1.4.1.2789.1247.1", "int", "2448816");

