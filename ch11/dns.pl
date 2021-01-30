#!/usr/bin/perl

#
# File: dns.pl
#
use Net::DNS;
use MyStats;

my $sleep = 30;
my $search = "www.oreilly.com";
my $mxSearch = "oreilly.com";
my $count = 3;
my $loadTime = 1;
my $duration = 3;
my $ns = "192.168.0.4";
my $debug = 0;
my $name1 = "DNS Server Watcher1";
my $message1 = "The DNS server $ns took greater than $loadTime second(s) to respond to queries. The problem persisted for over $duration seconds";

$stats = MyStats->new();
$stats->setSLA($name1,$duration,$loadTime,$message1);

my $start = 0;
my $stop = 0;
while(1){
   $start = time(); 
   my $res = Net::DNS::Resolver->new(
      nameservers => [$ns],
      debug       => $debug,
      );
   my $query = $res->search($search);
   if ($query) {
      foreach my $rr ($query->answer) {
           next unless $rr->type eq "A";
         print $rr->address, "\n";
      }
   } else {
      # You may want to create a new watcher for search errors
      warn "query failed: ", $res->errorstring, "\n";
   }

   # lookup MX records
   my @mx = mx($res, $mxSearch);
   if(@mx){
      foreach $rr (@mx) {
         print $rr->preference, " ", $rr->exchange, "\n";
      }
   } else {
      # You may want to create a new watcher for MX errors
      warn "Can't find MX records for $name: ", $res->errorstring, "\n";
   }
   $stop = time();
   my $total = sprintf("%.3f",($stop-$start));
   $stats->updateSLA($name1);
   $stats->sendAlert();
   print "Sleeping..\n";
   sleep($sleep);
}

