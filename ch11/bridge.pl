#!/usr/bin/perl

use SNMP::Info;

my $bridge = new SNMP::Info ( 
                             AutoSpecify => 1,
                             Debug       => 0,
                             DestHost    => '192.168.0.148', 
                             Community   => 'public',
                             Version     => 2
                             );

 my $class = $bridge->class();
 print " Using device sub class : $class\n";

 # Grab Forwarding Tables
 my $interfaces = $bridge->interfaces();
 my $fw_mac     = $bridge->fw_mac();
 my $fw_port    = $bridge->fw_port();
 my $bp_index   = $bridge->bp_index();

 foreach my $fw_index (keys %$fw_mac){
    my $mac   = $fw_mac->{$fw_index};
    my $bp_id = $fw_port->{$fw_index};
    my $iid   = $bp_index->{$bp_id};
    my $port  = $interfaces->{$iid};

    print "Port:$port forwarding to $mac\n";
 }

