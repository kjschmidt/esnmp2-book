#!/usr/bin/perl

use SNMP;
$SNMP::use_sprint_value = 1;
&SNMP::loadModules('IEEE802dot11-MIB');

my $host = "192.168.1.4";
my $sess = new SNMP::Session(DestHost => $host,
                                Version => 2,
                                Community => "public");

my %wapStats;
my $var = new SNMP::Varbind(['dot11CurrentChannel']);
do {
  $val = $sess->getnext($var);
  my $channel = $var->[$SNMP::Varbind::val_f];
  my $ifIndex = $var->[$SNMP::Varbind::iid_f];
  my($ssid, $mac, $manufacturer, $model, $rtsFailureCount,
  $ackFailureCount, $fcsErrorCount) = $sess->get([
        ['dot11DesiredSSID',$ifIndex],
        ['dot11MACAddress',$ifIndex],
        ['dot11ManufacturerID',$ifIndex],
        ['dot11ProductID',$ifIndex],
        ['dot11RTSFailureCount',$ifIndex],
        ['dot11ACKFailureCount',$ifIndex],
        ['dot11FCSErrorCount',$ifIndex]
        ]);
  $wapStats{$ifIndex} = "$channel,$ssid,$mac,$manufacturer,"
  $wapStats{$ifIndex} .= "$model,$rtsFailureCount,$ackFailureCount,$fcsErrorCount";
}unless($sess->{ErrorNum});

foreach my $key (sort keys %wapStats){
        my($channel, $ssid, $mac, $manufacturer, $model, 
        $rtsFailureCount, $ackFailureCount, $fcsErrorCount) =
                split(/,/,$wapStats{$key});

        print "WAP $ssid with MAC Address $mac (Manufacturer: $manufacturer, Model: $model, Channel: $channel, ifIndex: $key)\n";
        print "\tdot11RTSFailureCount: $rtsFailureCount\n";
        print "\tdot11ACKFailureCount: $ackFailureCount\n";
        print "\tdot11FCSErrorCount: $fcsErrorCount\n";
}

sub scoreChannel {
  my($rtsFailureCount, $ackFailureCount, $fcsErrorCount) = @_;
  return (.2 * $fcsErrorCount + .4 * $rtsFailureCount + 
    .4 * $ackFailureCount);
}

