#!/usr/bin/perl

use SNMP::Info;

my $info = new SNMP::Info( 
                            # Auto Discover more specific Device Class
                            AutoSpecify => 1,
                            Debug       => 0,
                            # The rest is passed to SNMP::Session
                            DestHost    => '192.168.0.148',
                            Community   => 'public',
                            Version     => 2 
                          ) or die "Can't connect to device.\n";

 my $err = $info->error();
 die "SNMP Community or Version probably wrong connecting to device. $err\n" if defined $err;

 $name  = $info->name();
 $class = $info->class();
 print "SNMP::Info is using this device class : $class\n";

 # Find out the Duplex status for the ports
 my $interfaces = $info->interfaces();
 my $i_duplex   = $info->i_duplex();

 # Get CDP Neighbor info
 my $c_if       = $info->c_if();
 my $c_ip       = $info->c_ip();
 my $c_port     = $info->c_port();

 # Print out data per port
 foreach my $iid (keys %$interfaces){
    my $duplex = $i_duplex->{$iid};
    # Print out physical port name, not snmp iid
    my $port  = $interfaces->{$iid};

    # The CDP Table has table entries different than the interface tables.
    # So we use c_if to get the map from cdp table to interface table.

    my %c_map = reverse %$c_if; 
    my $c_key = $c_map{$iid};
    my $neighbor_ip   = $c_ip->{$c_key};
    my $neighbor_port = $c_port->{$c_key};

    print "$port: $duplex duplex";
    print " connected to $neighbor_ip / $neighbor_port\n" if defined $remote_ip;
    print "\n";
 }

