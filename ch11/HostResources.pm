package SNMP::Info::HostResources;

$VERSION = 1.0;

use strict;

use Exporter;
use SNMP::Info;

@SNMP::Info::HostResources::ISA = qw/SNMP::Info Exporter/;
@SNMP::Info::HostResources::EXPORT_OK = qw//;

use vars qw/$VERSION %FUNCS %GLOBALS %MIBS %MUNGE $AUTOLOAD $INIT $DEBUG/;

%MIBS    = (%SNMP::Info::MIBS,
            'HOST-RESOURCES-MIB'  => 'host',
   );

%GLOBALS = (%SNMP::Info::GLOBALS,
            'hr_users' => 'hrSystemNumUsers',
            'hr_processes' => 'hrSystemProcesses',
            'hr_date' => 'hrSystemDate',
            );

%FUNCS   = (%SNMP::Info::FUNCS,
            # HostResources MIB objects
            'hr_sindex'  => 'hrStorageIndex',
            'hr_sdescr'  => 'hrStorageDescr',
            'hr_sused'  => 'hrStorageUsed',
           );

%MUNGE   = (%SNMP::Info::MUNGE,
            'hr_date' => \&munge_hrdate,
           );

sub munge_hrdate {
   my($oct) = @_;
   #
   # hrSystemDate has a syntax of DateAndTime, which is defined in SNMPv2-TC as
   #
   #DateAndTime ::= TEXTUAL-CONVENTION
   # DISPLAY-HINT "2d-1d-1d,1d:1d:1d.1d,1a1d:1d"
   # STATUS       current
   # DESCRIPTION
   #         "A date-time specification.
   #
   #            field  octets  contents                  range
   #            -----  ------  --------                  -----
   #              1      1-2   year*                     0..65536
   #              2       3    month                     1..12
   #              3       4    day                       1..31
   #              4       5    hour                      0..23
   #              5       6    minutes                   0..59
   #              6       7    seconds                   0..60
   #                           (use 60 for leap-second)
   #              7       8    deci-seconds              0..9
   #              8       9    direction from UTC        '+' / '-'
   #              9      10    hours from UTC*           0..13
   #             10      11    minutes from UTC          0..59
   #
   #            * Notes:
   #            - the value of year is in network-byte order
   #            - daylight saving time in New Zealand is +13
   #
   #            For example, Tuesday May 26, 1992 at 1:30:15 PM EDT would be
   #            displayed as:
   #
   #                             1992-5-26,13:30:15.0,-4:0
   #
   #            Note that if only local time is known, then timezone
   #            information (fields 8-10) is not present."
   #    SYNTAX       OCTET STRING (SIZE (8 | 11))
   #

   my ($year1, $year2, $month, $day, $hour, $min, $secs, $decisecs,
         $direction, $hoursFromUTC, $minFromUTC) = split(/ /, sprintf("%d %d %d %d %d %d %d %d %d %d %d",unpack('C*',$oct)));
   my $value = 0;
   $direction = chr($direction);
   $value = $value * 256 + $year1;
   $value = $value * 256 + $year2;
   my $year = $value;
   return
      "$year-$month-$day,$hour:$min:$secs:$decisecs,$direction$hoursFromUTC:$minFromUTC";
}

1; # don't forget this line

