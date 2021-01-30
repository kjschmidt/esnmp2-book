#!/usr/local/bin/perl
# Find and dels core files. It sends traps upon completion and
# errors. Arguments are:
# -path directory   : search directory (and subdirectories); default /
# -lookfor filename : filename to search for; default core
# -debug value      : debug level

while ($ARGV[0] =~ /^-/)
{    if    ($ARGV[0] eq "-path")    { shift; $PATH    = $ARGV[0]; }
    elsif ($ARGV[0] eq "-lookfor") { shift; $LOOKFOR = $ARGV[0]; }
    elsif ($ARGV[0] eq "-debug")   { shift; $DEBUG   = $ARGV[0]; }
    shift;
}

#################################################################
##########################  Begin Main  #########################
#################################################################
require "find.pl";     # This gives us the find function.
$LOOKFOR = "core" unless ($LOOKFOR); # If we don't have something
                                     # in $LOOKFOR then default
                                     # to core
$PATH    = "/"    unless ($PATH);    # Let's use / if we don't get
                                     # one on the command line
(-d $PATH) || die "$PATH is NOT a valid dir!";    # We can only
                                                  # search valid
                                                  # directories
&find("$PATH");
#################################################################
######################  Begin SubRoutines  ######################
#################################################################
sub wanted
{    if (/^$LOOKFOR$/)
        {
            if (!(-d $name)) # Skip the directories named core
            {
               &get_stats;
               &can_file;
               &send_trap;
            }
        }
}
sub can_file
{    print "Deleting :$_: :$name:\n" unless (!($DEBUG));
    $RES = unlink "$name";
    if ($RES != 1) { $ERROR = 1; }
}
sub get_stats
{    chop ($STATS =  `ls -l $name` );
    chop ($FILE_STATS =  `/bin/file $name` );
    $STATS =~ s/\s+/ /g;
    $FILE_STATS =~ s/\s+/ /g;
}
sub send_trap
{
    if ($ERROR == 0) { $SPEC = 1535; }
    else             { $SPEC = 1536; }
    print "STATS: $STATS\n" unless (!($DEBUG));
    print "FILE_STATS: $FILE_STATS\n" unless (!($DEBUG));

# Sending a trap using Net-SNMP
##system "/usr/local/bin/snmptrap nms public .1.3.6.1.4.1.2789.2500 '' 6 $SPEC '' \
#.1.3.6.1.4.1.2789.2500.1535.1 s \"$name\" \
#.1.3.6.1.4.1.2789.2500.1535.2 s \"$STATS\" \
#.1.3.6.1.4.1.2789.2500.1535.3 s \"$FILE_STATS\"";


# Sending a trap using Perl
#use SNMP_util "0.54";  # This will load the BER and SNMP_Session for us
snmptrap("public\@nms:162", ".1.3.6.1.4.1.2789.2500", mylocalhostname, 6, $SPEC, \
".1.3.6.1.4.1.2789.2500.1535.1", "string", "$name", \
".1.3.6.1.4.1.2789.2500.1535.2", "string", "$STATS", \
".1.3.6.1.4.1.2789.2500.1535.3", "string", "$FILE_STATS");


# Sending a trap using OpenView's snmptrap
##system "/opt/OV/bin/snmptrap -c public nms \
#.1.3.6.1.4.1.2789.2500 \"\" 6 $SPEC \"\" \
#.1.3.6.1.4.1.2789.2500.1535.1 octetstringascii \"$name\" \
#.1.3.6.1.4.1.2789.2500.1535.2 octetstringascii \"$STATS\" \
#.1.3.6.1.4.1.2789.2500.1535.3 octetstringascii \"$FILE_STATS\"";
}

