#!/usr/local/bin/perl
## Filename: /opt/local/mib_programs/os/iamin.pl

chomp ($WHO =  `/bin/who am i \| awk \{\'print \$1\'\}` );
exit 123 unless ($WHO ne '');
chomp ($WHOAMI =  `/usr/ucb/whoami` );
chomp ($TTY =  `/bin/tty` );
chomp ($FROM =  `/bin/last \-1 $WHO \| /bin/awk \{\'print \$3\'\}` );
if ($FROM =~ /Sun|Mon|Tue|Wed|Thu|Fri|Sat/) { $FROM = "N/A"; }

# DEBUG BELOW
# print "WHO :$WHO:\n"; print "WHOAMI :$WHOAMI:\n"; print "FROM :$FROM:\n";
if ("$WHOAMI" ne "$WHO") { $WHO = "$WHO\-\>$WHOAMI"; }

# Sending a trap using Net-SNMP
#
system "/usr/local/bin/snmptrap nms public .1.3.6.1.4.1.2789.2500 '' 6 1502 '' \
.1.3.6.1.4.1.2789.2500.1502.1 s \"$WHO\" \
.1.3.6.1.4.1.2789.2500.1502.2 s \"$FROM\" \
.1.3.6.1.4.1.2789.2500.1502.3 s \"$TTY\"";

# Sending a trap using Perl
##use SNMP_util "0.54";  # This will load the BER and SNMP_Session for us
#snmptrap("public\@nms:162", ".1.3.6.1.4.1.2789.2500", mylocalhostname, 6, 1502, \
#".1.3.6.1.4.1.2789.2500.1502.1", "string", "$WHO", \
#".1.3.6.1.4.1.2789.2500.1502.2", "string", "$FROM", \
#".1.3.6.1.4.1.2789.2500.1502.3", "string", "$TTY");


# Sending a trap using OpenView's snmptrap
##system "/opt/OV/bin/snmptrap -c public nms .1.3.6.1.4.1.2789.2500 \"\" 6 1502 \"\" \
#.1.3.6.1.4.1.2789.2500.1502.1 octetstringascii \"$WHO\" \
#.1.3.6.1.4.1.2789.2500.1502.2 octetstringascii \"$FROM\" \
#.1.3.6.1.4.1.2789.2500.1502.3 octetstringascii \"$TTY\"";
#
#print "\n##############\n";
print "#   NOTICE   \# - You have been logged: :$WHO: :$FROM: :$TTY: \n"; #
print "##############\n\n";

