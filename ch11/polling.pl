#!/usr/local/bin/perl
# filename: polling.pl
# options:
#    -min n    : send trap if less than n 1024-byte blocks free
#    -table f  : table of servers to watch (defaults to ./default)
#    -server s : specifies a single server to poll
#    -inst n   : number of leading instance-number digits to compare
#    -debug n  : debug level

$|++;
$SNMPWALK_LOC  = "/opt/OV/bin/snmpwalk -r 5";
$SNMPGET_LOC   = "/opt/OV/bin/snmpget";
$HOME_LOC      = "/opt/OV/local/bin/disk_space";
$LOCK_FILE_LOC = "$HOME_LOC/lock_files";
$GREP_LOC      = "/bin/grep";
$TOUCH_LOC     = "/bin/touch";
$PING_LOC      = "/usr/sbin/ping";       # Ping Location
$PING_TIMEOUT  = 7;                      # Seconds to wait for a ping
$MIB_C = ".1.3.6.1.4.1.11.2.3.1.2.2.1.6";       # fileSystemBavail;
$MIB_BSIZE = ".1.3.6.1.4.1.11.2.3.1.2.2.1.7";  # fileSystemBsize
$MIB_DIR = ".1.3.6.1.4.1.11.2.3.1.2.2.1.10";   # fileSystemDir
while ($ARGV[0] =~ /^-/)
{    if    ($ARGV[0] eq "-min")    { shift; $MIN = $ARGV[0]; }   # In 1024 blocks
    elsif ($ARGV[0] eq "-table")  { shift; $TABLE = $ARGV[0]; }
    elsif ($ARGV[0] eq "-server") { shift; $SERVER = $ARGV[0]; }
    elsif ($ARGV[0] eq "-inst")   { shift; $INST_LENGTH = $ARGV[0]; }
    elsif ($ARGV[0] eq "-debug")  { shift; $DEBUG = $ARGV[0]; }
    shift;
}
#################################################################
##########################  Begin Main  #########################
#################################################################
$ALLSERVERS  = 1 unless ($SERVER);
$INST_LENGTH = 5 unless ($INST_LENGTH);
$TABLE = "default" unless ($TABLE);
open(TABLE,"$HOME_LOC/$TABLE") || die "Can't Open File $TABLE";
while($LINE=<TABLE>)
{    if ($LINE ne "\n")
    {
    chop $LINE;
    ($HOST,$IGNORE1,$IGNORE2,$IGNORE3) = split(/\:/,$LINE);
    if (&ping_server_bad("$HOST")) { warn "Can't Ping Server
       :$HOST:" unless (!($DEBUG)); }
    else
    {
        &find_inst;
        if ($DEBUG > 99)
        {
        print "HOST:$HOST: IGNORE1 :$IGNORE1: IGNORE2 :$IGNORE2:
              IGNORE3 :$IGNORE3:\n";
        print "Running :$SNMPWALK_LOC $HOST $MIB_C \| $GREP_LOC
              \.$GINST:\n";
        }
        $IGNORE1 = "C1ANT5MAT9CHT4HIS"
                 unless ($IGNORE1); # If we don't have anything then let's set
        $IGNORE2 = "CA2N4T6M8A1T3C5H7THIS"
                 unless ($IGNORE2); # to something that we can never match.
        $IGNORE3 = "CAN3TMA7TCH2THI6S" unless ($IGNORE3);
        if (($SERVER eq "$HOST") || ($ALLSERVERS))
        {
          open(WALKER,"$SNMPWALK_LOC $HOST $MIB_C \| $GREP_LOC
             \.$GINST |") || die "Can't Walk $HOST $MIB_C\n";
          while($WLINE=<WALKER>)
          {
              chop $WLINE;
              ($MIB,$TYPE,$VALUE) = split(/\:/,$WLINE);
              $MIB =~ s/\s+//g;
              $MIB =~ /(\d+\.\d+)$/;
              $INST = $1;
              open(SNMPGET,"$SNMPGET_LOC $HOST $MIB_DIR $INST |");
              while($DLINE=<SNMPGET>)
              {
                  ($NULL,$NULL,$DNAME) = split(/\:/,$DLINE);
              }
              $DNAME =~ s/\s+//g;
              close SNMPGET;
              open(SNMPGET,"$SNMPGET_LOC $HOST $MIB_BSIZE $INST |");
              while($BLINE=<SNMPGET>)
              {
              ($NULL,$NULL,$BSIZE) = split(/\:/,$BLINE);
              }
              close SNMPGET;
              $BSIZE =~ s/\s+//g;
              $LOCK_RES = &inst_found; $LOCK_RES = "\[ $LOCK_RES \]";
              print "LOCK_RES :$LOCK_RES:\n" unless ($DEBUG < 99);
              $VALUE = $VALUE * $BSIZE / 1024; # Put it in 1024 blocks
              if (($DNAME =~ /.*$IGNORE1.*/) ||
                 ($DNAME =~ /.*$IGNORE2.*/) ||
                 ($DNAME =~ /.*$IGNORE3.*/))
              {
                 $DNAME = "$DNAME  ignored ";
              }
              else
              {
                  if (($VALUE <= $MIN) && ($LOCK_RES eq "\[ 0 \]"))
                  {
                     &write_lock;
                     &send_snmp_trap(0);
                  }
                  elsif (($VALUE > $MIN) && ($LOCK_RES eq "\[ 1 \]"))
                  {
                     &remove_lock;
                     &send_snmp_trap(1);
                  }
              }
              $VALUE = $VALUE / $BSIZE * 1024; # Display it as the
                                               # original block size
              write unless (!($DEBUG));
          } # end while($WLINE=<WALKER>)
       }     # end if (($SERVER eq "$HOST") || ($ALLSERVERS))
   }         # end else from if (&ping_server_bad("$HOST"))
    }             # end if ($LINE ne "\n")
}                 # end while($LINE=<TABLE>)
#################################################################
######################  Begin SubRoutines  ######################
#################################################################
format STDOUT_TOP =
Server    MountPoint          BlocksLeft    BlockSize    MIB       LockFile
--------  ------------------  ------------  -----------  --------  ----------
.
format STDOUT =
@<<<<<<<<<< @<<<<<<<<<<<<  @<<<<<<<<<  @<<<<<<<<  @<<<<<<<<<<<<<< @<<<<
$HOST,      $DNAME,        $VALUE,     $BSIZE,    $INST, $LOCK_RES
.
sub inst_found
{    if (-e "$LOCK_FILE_LOC/$HOST\.$INST") { return 1; }
    else { return 0; }
}
sub remove_lock
{    if ($DEBUG > 99) { print "Removing Lockfile $LOCK_FILE_LOC/$HOST\.$INST\n"; }
    unlink "$LOCK_FILE_LOC/$HOST\.$INST";
}
sub write_lock
{    if ($DEBUG > 99) { print "Writing Lockfile
         $TOUCH_LOC $LOCK_FILE_LOC/$HOST\.$INST\n"; }
    system "$TOUCH_LOC $LOCK_FILE_LOC/$HOST\.$INST";
}
#################################################################
## send_snmp_trap ##
####################
##
# This subroutine allows you to send diff traps depending on the
#  passed parm and gives you a chance to send both good and bad
#  traps.
## $1 - integer - This will be added to the specific event ID.
## If we created two traps:
#  2789.2500.0.1000 = Major
#  2789.2500.0.1001 = Good
## If we declare:
#  $SNMP_SPECIFIC_TRAP     = "1000";
## We could send the 1st by using:
#  send_snmp_trap(0);  # Here is the math (1000 + 0 = 1000)
#  And to send the second one:
#  send_snmp_trap(1);  # Here is the math (1000 + 1 = 1001)
## This way you could set up multiple traps with diff errors using
# the same function for all.
####################################################################
sub send_snmp_trap
{    $TOTAL_TRAPS_CREATED    = 2;  # Let's do some checking/reminding
                                  # here. This number should the
                                  # total number of traps that you
                                  # created on nms.
    $SNMP_ENTERPRISE_ID     = ".1.3.6.1.4.1.2789.2500";
    $SNMP_SPECIFIC_TRAP     = "1500";
    $PASSED_PARM            = $_[0];
    $SNMP_SPECIFIC_TRAP    += $PASSED_PARM;
    $SNMP_TRAP_LOC          = "/opt/OV/bin/snmptrap";
    $SNMP_COMM_NAME         = "public";
    $SNMP_TRAP_HOST         = "nms";
    $SNMP_GEN_TRAP          = "6";
    chop($SNMP_TIME_STAMP        = "1" .  `date +%H%S` );
    $SNMP_EVENT_IDENT_ONE   = ".1.3.6.1.4.1.2789.2500.$SNMP_SPECIFIC_TRAP.1";
    $SNMP_EVENT_VTYPE_ONE   = "octetstringascii";
    $SNMP_EVENT_VAR_ONE     = "$DNAME";
    $SNMP_EVENT_IDENT_TWO   = ".1.3.6.1.4.1.2789.2500.$SNMP_SPECIFIC_TRAP.2";
    $SNMP_EVENT_VTYPE_TWO   = "integer";
    $SNMP_EVENT_VAR_TWO     = "$VALUE";
    $SNMP_EVENT_IDENT_THREE = ".1.3.6.1.4.1.2789.2500.$SNMP_SPECIFIC_TRAP.3";
    $SNMP_EVENT_VTYPE_THREE = "integer";
    $SNMP_EVENT_VAR_THREE   = "$BSIZE";
    $SNMP_EVENT_IDENT_FOUR  = ".1.3.6.1.4.1.2789.2500.$SNMP_SPECIFIC_TRAP.4";
    $SNMP_EVENT_VTYPE_FOUR  = "octetstringascii";
    $SNMP_EVENT_VAR_FOUR    = "$INST";
    $SNMP_EVENT_IDENT_FIVE  = ".1.3.6.1.4.1.2789.2500.$SNMP_SPECIFIC_TRAP.5";
    $SNMP_EVENT_VTYPE_FIVE  = "integer";
    $SNMP_EVENT_VAR_FIVE    = "$MIN";
    $SNMP_TRAP = "$SNMP_TRAP_LOC \-c $SNMP_COMM_NAME $SNMP_TRAP_HOST
      $SNMP_ENTERPRISE_ID \"$HOST\" $SNMP_GEN_TRAP $SNMP_SPECIFIC_TRAP
      $SNMP_TIME_STAMP
      $SNMP_EVENT_IDENT_ONE   $SNMP_EVENT_VTYPE_ONE   \"$SNMP_EVENT_VAR_ONE\"
      $SNMP_EVENT_IDENT_TWO   $SNMP_EVENT_VTYPE_TWO   \"$SNMP_EVENT_VAR_TWO\"
      $SNMP_EVENT_IDENT_THREE $SNMP_EVENT_VTYPE_THREE \"$SNMP_EVENT_VAR_THREE\"
      $SNMP_EVENT_IDENT_FOUR  $SNMP_EVENT_VTYPE_FOUR  \"$SNMP_EVENT_VAR_FOUR\"
      $SNMP_EVENT_IDENT_FIVE  $SNMP_EVENT_VTYPE_FIVE  \"$SNMP_EVENT_VAR_FIVE\"";
    if (!($PASSED_PARM < $TOTAL_TRAPS_CREATED))
    {
       die "ERROR SNMPTrap With A Specific Number \>
           $TOTAL_TRAPS_CREATED\nSNMP_TRAP:$SNMP_TRAP:\n";
    }
    # Sending a trap using Net-SNMP
    #
    #system "/usr/local/bin/snmptrap $SNMP_TRAP_HOST $SNMP_COMM_NAME $SNMP_ENTERPRISE_ID '' $SNMP_GEN_TRAP $SNMP_SPECIFIC_TRAP '' \
    #$SNMP_EVENT_IDENT_ONE s \"$SNMP_EVENT_VAR_ONE\" \
    #$SNMP_EVENT_IDENT_TWO i"$SNMP_EVENT_VAR_TWO\"
    #$SNMP_EVENT_IDENT_THREE i \"$SNMP_EVENT_VAR_THREE\"
    #$SNMP_EVENT_IDENT_FOUR s \"$SNMP_EVENT_VAR_FOUR\"";
    #$SNMP_EVENT_IDENT_FIVE i \"$SNMP_EVENT_VAR_FIVE\"";
    # Sending a trap using Perl
    #
    #use SNMP_util "0.54";  # This will load the BER and SNMP_Session for us
    #snmptrap("$SNMP_COMM_NAME\@$SNMP_TRAP_HOST:162", "$SNMP_ENTERPRISE_ID", mylocalhostname, $SNMP_GEN_TRAP, $SNMP_SPECIFIC_TRAP, \
    #"$SNMP_EVENT_IDENT_ONE", "string", "$SNMP_EVENT_VAR_ONE", \
    #"$SNMP_EVENT_IDENT_TWO", "int", "$SNMP_EVENT_VAR_TWO", \
    #"$SNMP_EVENT_IDENT_THREE", "int", "$SNMP_EVENT_VAR_THREE", \
    #"$SNMP_EVENT_IDENT_FOUR", "string", "$SNMP_EVENT_VAR_FOUR", \
    #"$SNMP_EVENT_IDENT_FIVE", "int", "$SNMP_EVENT_VAR_FIVE");
    # Sending a trap using OpenView's snmptrap (using VARs from above)
    #
    $SEND_SNMP_TRAP         = system "$SNMP_TRAP";
    print "ERROR Running SnmpTrap Result :$SEND_SNMP_TRAP: :$SNMP_TRAP:\n"
unless (!($SEND_SNMP_TRAP));
}
sub find_inst
{    open(SNMPWALK2,"$SNMPWALK_LOC $HOST $MIB_DIR |") ||
                                die "Can't Find Inst for $HOST\n";
    while($DLINE=<SNMPWALK2>)
    {
      chomp $DLINE;
      ($DIRTY_INST,$NULL,$DIRTY_NAME) = split(/\:/,$DLINE);
      $DIRTY_NAME =~ s/\s+//g;  # Loose the white space folks!
      print "DIRTY_INST :$DIRTY_INST:\nDIRTY_NAME :$DIRTY_NAME:\n"
                            unless (!($DEBUG>99));
        if ($DIRTY_NAME eq "/")
        {
            $DIRTY_INST =~ /fileSystemDir\.(\d*)\.1/;
            $GINST = $1;
            $LENGTH = (length($GINST) - $INST_LENGTH);
            while ($LENGTH--) { chop $GINST; }
            close SNMPWALK;
            print "Found Inst DIRTY_INST :$DIRTY_INST: DIRTY_NAME\
                 :$DIRTY_NAME: GINST :$GINST:\n"
                            unless (!($DEBUG > 99));
            return 0;
        }
    }
    close SNMPWALK2;
    die "Can't Find Inst For HOST :$HOST:";
}
sub ping_server_bad
{    local $SERVER  = $_[0];
    $RES = system "$PING_LOC $SERVER $PING_TIMEOUT \> /dev/null";
    print "Res From Ping :$RES: \- :$PING_LOC $SERVER:\n"
                                          unless (!($DEBUG));
    return $RES;
}

