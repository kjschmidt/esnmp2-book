#!/usr/local/bin/perl
# Filename: /opt/local/perl_scripts/check4file.pl
use SNMP_util "0.54";  # This will load the BER and SNMP_Session for us
$FILENAME = "/etc/passwd";
#
# if the /etc/passwd file does not exist, send a trap!
#
if(!(-e $FILENAME)) {
    snmptrap("public\@nms:162", ".1.3.6.1.4.1.2789", "sunserver1", 6, 1547, \
             ".1.3.6.1.4.1.2789.1547.1", "string", "File \:$FILENAME\: Could\
             NOT Be Found");
}

