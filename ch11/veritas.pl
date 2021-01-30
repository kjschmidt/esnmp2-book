#!/usr/local/bin/perl -wc

$VXPRINT_LOC    = "/usr/sbin/vxprint";
$HOSTNAME       =  `/bin/uname -n` ; chop $HOSTNAME;

while ($ARGV[0] =~ /^-/)
{    if    ($ARGV[0] eq "-debug")        { shift; $DEBUG = $ARGV[0]; }
    elsif ($ARGV[0] eq "-state_active") { $SHOW_STATE_ACTIVE = 1; }
    shift;
}

####################################################################
###########################  Begin Main  ###########################
####################################################################
&get_vxprint;  # Get it, process it, and send traps if errors found!
####################################################################
########################  Begin SubRoutines  #######################
####################################################################
sub get_vxprint
{
    open(VXPRINT,"$VXPRINT_LOC |") || die "Can't Open $VXPRINT_LOC";
    while($VXLINE=<VXPRINT>)
    {
        print $VXLINE unless ($DEBUG < 2);
        if ($VXLINE ne "\n")
        {
            &is_a_disk_group_name;
            &split_vxprint_output;
            if (($TY ne "TY")   &&
                ($TY ne "Disk") &&
                ($TY ne "dg")   &&
                ($TY ne "dm"))
            {
                if (($SHOW_STATE_ACTIVE) && ($STATE eq "ACTIVE"))
                {
                    print "ACTIVE: $VXLINE";
                }
                if (($STATE ne "ACTIVE") &&
                    ($STATE ne "DISABLED") &&
                    ($STATE ne "SYNC") &&
                    ($STATE ne "CLEAN") &&
                    ($STATE ne "SPARE") &&
                    ($STATE ne "-")      &&
                    ($STATE ne ""))
                {
                    &send_error_msgs;
                }
                elsif (($KSTATE ne "ENABLED") &&
                       ($KSTATE ne "DISABLED") &&
                       ($KSTATE ne "-")       &&
                       ($KSTATE ne ""))
                {
                    &send_error_msgs;
                }
            } # end if (($TY
        }     # end if ($VXLINE
    }         # end while($VXLINE
}             # end sub get_vxprint
sub is_a_disk_group_name
{    if ($VXLINE =~ /^Disk\sgroup\:\s(\w+)\n/)
    {
        $DISK_GROUP = $1;
        print "Found Disk Group :$1:\n" unless (!($DEBUG));
        return 1;
    }
}
sub split_vxprint_output
{    ($TY, $NAME, $ASSOC, $KSTATE, $LENGTH, $PLOFFS, $STATE, $TUTIL0, $PUTIL0) =
split(/\s+/,$VXLINE);
    if ($DEBUG) {
        print "SPLIT: $TY $NAME $ASSOC $KSTATE $LENGTH $PLOFFS $STATE $TUTIL0
$PUTIL0:\n";
    }
}
sub send_snmp_trap
{    $SNMP_TRAP_LOC          = "/opt/OV/bin/snmptrap";
    $SNMP_COMM_NAME         = "public";
    $SNMP_TRAP_HOST         = "nms";
    $SNMP_ENTERPRISE_ID     = ".1.3.6.1.4.1.2789.2500";
    $SNMP_GEN_TRAP          = "6";
    $SNMP_SPECIFIC_TRAP     = "1000";
    chop($SNMP_TIME_STAMP        = "1" .  `date +%H%S` );
    $SNMP_EVENT_IDENT_ONE   = ".1.3.6.1.4.1.2789.2500.1000.1";
    $SNMP_EVENT_VTYPE_ONE   = "octetstringascii";
    $SNMP_EVENT_VAR_ONE     = "$HOSTNAME";
    $SNMP_EVENT_IDENT_TWO   = ".1.3.6.1.4.1.2789.2500.1000.2";
    $SNMP_EVENT_VTYPE_TWO   = "octetstringascii";
    $SNMP_EVENT_VAR_TWO     = "$NAME";
    $SNMP_EVENT_IDENT_THREE = ".1.3.6.1.4.1.2789.2500.1000.3";
    $SNMP_EVENT_VTYPE_THREE = "octetstringascii";
    $SNMP_EVENT_VAR_THREE   = "$STATE";
    $SNMP_EVENT_IDENT_FOUR  = ".1.3.6.1.4.1.2789.2500.1000.4";
    $SNMP_EVENT_VTYPE_FOUR  = "octetstringascii";
    $SNMP_EVENT_VAR_FOUR    = "$DISK_GROUP";
    $SNMP_TRAP = "$SNMP_TRAP_LOC \-c $SNMP_COMM_NAME $SNMP_TRAP_HOST
    $SNMP_ENTERPRISE_ID \"\" $SNMP_GEN_TRAP $SNMP_SPECIFIC_TRAP $SNMP_TIME_STAMP
    $SNMP_EVENT_IDENT_ONE   $SNMP_EVENT_VTYPE_ONE   \"$SNMP_EVENT_VAR_ONE\"
    $SNMP_EVENT_IDENT_TWO   $SNMP_EVENT_VTYPE_TWO   \"$SNMP_EVENT_VAR_TWO\"
    $SNMP_EVENT_IDENT_THREE $SNMP_EVENT_VTYPE_THREE \"$SNMP_EVENT_VAR_THREE\"
    $SNMP_EVENT_IDENT_FOUR  $SNMP_EVENT_VTYPE_FOUR  \"$SNMP_EVENT_VAR_FOUR\"";
    # Sending a trap using Net-SNMP
    #
    #system "/usr/local/bin/snmptrap $SNMP_TRAP_HOST $SNMP_COMM_NAME $SNMP_ENTERPRISE_ID '' $SNMP_GEN_TRAP $SNMP_SPECIFIC_TRAP '' \
    #$SNMP_EVENT_IDENT_ONE s \"$SNMP_EVENT_VAR_ONE\" \
    #$SNMP_EVENT_IDENT_TWO s"$SNMP_EVENT_VAR_TWO\"
    #$SNMP_EVENT_IDENT_THREE s \"$SNMP_EVENT_VAR_THREE\"
    #$SNMP_EVENT_IDENT_FOUR s \"$SNMP_EVENT_VAR_FOUR\"";
    # Sending a trap using Perl
    #
    #use SNMP_util "0.54";  # This will load the BER and SNMP_Session for us
    #snmptrap("$SNMP_COMM_NAME\@$SNMP_TRAP_HOST:162", "$SNMP_ENTERPRISE_ID",mylocalhostname, $SNMP_GEN_TRAP, $SNMP_SPECIFIC_TRAP, \
    #"$SNMP_EVENT_IDENT_ONE", "string", "$SNMP_EVENT_VAR_ONE", \
    #"$SNMP_EVENT_IDENT_TWO", "string", "$SNMP_EVENT_VAR_TWO", \
    #"$SNMP_EVENT_IDENT_THREE", "string", "$SNMP_EVENT_VAR_THREE", \
    #"$SNMP_EVENT_IDENT_FOUR", "string", "$SNMP_EVENT_VAR_FOUR");
    # Sending a trap using OpenView's snmptrap (using VARs from above)
    #
    $SEND_SNMP_TRAP       = system "$SNMP_TRAP";
    print "Problem Running SnmpTrap With Result :$SEND_SNMP_TRAP: :$SNMP_TRAP:\n"
unless (!($SEND_SNMP_TRAP));
} # end sub send_snmp_trap
sub send_error_msgs
{    $TY =~ s/^v/Volume/;
    $TY =~ s/^pl/Plex/;
    $TY =~ s/^sd/SubDisk/;
    print "VXfs Problem: Host:[$HOSTNAME] State:[$STATE] DiskGroup:[$DISK_GROUP]
        Type:[$TY] FileSystem:[$NAME] Assoc:[$ASSOC] Kstate:[$KSTATE]\n"
        unless (!($DEBUG));
    &send_snmp_trap;
}

