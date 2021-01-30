#!/usr/local/bin/perl
# filename: mail_poller.pl
$HOME_LOC     = "/opt/OV/local/bin/netcat";
$NC_LOC       = "/opt/netcat/nc";
$DIFF_LOC     = "/bin/diff";
$ECHO_LOC     = "/bin/echo";
$MAIL_SERVER  = "mail.exampledomain.com";
$MAIL_PORT    =  25;
$INPUT_FILE   = "$HOME_LOC\/input.txt";
$GOOD_FILE    = "$HOME_LOC\/mail_good";
$CURRENT_FILE = "$HOME_LOC\/mail_current";
$EXIT_FILE    = "$HOME_LOC\/mail_status";
$DEBUG = 0;
print "$NC_LOC -i 1 -w 3 $MAIL_SERVER $MAIL_PORT
    \< $INPUT_FILE \> $CURRENT_FILE\n" unless (!($DEBUG));
$NETCAT_RES = system "$NC_LOC -i 1 -w 3 $MAIL_SERVER $MAIL_PORT
    \< $INPUT_FILE \> $CURRENT_FILE";
$NETCAT_RES = $NETCAT_RES / 256;
if ($NETCAT_RES)
{    # We had a problem with netcat... maybe a timeout?
    system "$ECHO_LOC $NETCAT_RES > $EXIT_FILE";
    &cleanup;
}
$DIFF_RES = system "$DIFF_LOC $GOOD_FILE $CURRENT_FILE";
$DIFF_RES = $DIFF_RES / 256;
if ($DIFF_RES)
{    # looks like things are different!
    system "$ECHO_LOC $DIFF_RES > $EXIT_FILE";
    &cleanup;
}else
{    # All systems go!
    system "$ECHO_LOC 0 > $EXIT_FILE";
    &cleanup;
}
sub cleanup
{   unlink "$CURRENT_FILE";
   exit 0;
}
