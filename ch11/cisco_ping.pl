#!/usr/bin/perl

use SNMP;

#
# This script was adapted from the one that comes with Net-SNMP
#

my %ipsToPing = (
      "192.168.0.48" => 333,
);

my $router = "192.168.0.130";
my $community = "public";
my $version = 1;

my $sess = new SNMP::Session (DestHost => $router,
	      Community => $community,
          Retries => 1,
          Version => $version);

my $ciscoPingEntry = ".1.3.6.1.4.1.9.9.16.1.1.1";
my $ciscoPingEntryStatus = "$ciscoPingEntry.16";
my $ciscoPingEntryOwner = "$ciscoPingEntry.15";
my $ciscoPingProtocol = "$ciscoPingEntry.2";
my $ciscoPingPacketCount = "$ciscoPingEntry.4";
my $ciscoPingPacketSize = "$ciscoPingEntry.5";
my $ciscoPingAddress = "$ciscoPingEntry.3";
my $ciscoPingSentPackets = "$ciscoPingEntry.9";
my $ciscoPingReceivedPackets = "$ciscoPingEntry.10";
my $ciscoPingMinRtt = "$ciscoPingEntry.11";
my $ciscoPingAvgRtt = "$ciscoPingEntry.12";
my $ciscoPingMaxRtt = "$ciscoPingEntry.13";
my $ciscoPingCompleted = "$ciscoPingEntry.14";

#
# Set up Cisco Ping table with targets we want to ping
#
foreach my $target (sort keys %ipsToPing){
    my $row = $ipsToPing{$target};
    # We must encode the IP we want to ping to HEX
    my $dec = pack("C*",split /\./, $target);
    $sess->set([
        # First we clear the entry for this target
        [$ciscoPingEntryStatus, $row, 6, "INTEGER"],
        # Now we create a new entry for this target
        [$ciscoPingEntryStatus, $row, 5, "INTEGER"],
        # Set the owner of this entry
        [$ciscoPingEntryOwner, $row, "kjs", "OCTETSTR"],
        # Set the protocol to use, in this case "1" is IP
        [$ciscoPingProtocol, $row, 1, "INTEGER"],
        # Set the number of packets to send
        [$ciscoPingPacketCount, $row, 20, "INTEGER"],
        # Set the packet size
        [$ciscoPingPacketSize, $row, 150, "INTEGER"],
        # Finally set the target we want to ping
        [$ciscoPingAddress, $row, $dec, "OCTETSTR"]]);
    
    # This enables this target and causes the router to start pinging
    $sess->set([[$ciscoPingEntryStatus, $row, 1, "INTEGER"]]);

    if($sess->{ErrorStr}){
       print "An Error Occurred: $sess->{ErrorStr}\n";
       exit;
    }
}

# Give router time to do its thing...
sleep 30;

#
# Get results
#
foreach my $target (sort keys %ipsToPing){
   my $row = $ipsToPing{$target};
   my ($sent, $received, $low, $avg, $high, $completed) = $sess->get([
      [$ciscoPingSentPackets, $row], [$ciscoPingReceivedPackets, $row], 
      [$ciscoPingMinRtt, $row], [$ciscoPingAvgRtt, $row], 
      [$ciscoPingMaxRtt, $row], [$ciscoPingCompleted, $row]]);

   printf "($target)Packet loss: %d% (%d/%d)\n", (100 * ($sent-$received)) / $sent,
        $received, $sent;
   print "Average delay $avg (low: $low high: $high)\n";
   # Here we remove this target's entry from the Cisco Ping Table
   $sess->set([$ciscoPingEntryStatus, $row, 6, "INTEGER"]);
 }

