#!/usr/bin/perl

#
# File: agent.pl
#

use NetSNMP::agent (':all');
use NetSNMP::default_store (':all');
use NetSNMP::ASN (':all');
use NetSNMP::OID;
use SNMP;

my $port = "9161";
my $host = ".1.3.6.1.4.1.8072.25";
my $hrMemorySize = $host.".2.2";

sub myHandler{
   my ($handler, $registration_info, $request_info, $requests) = @_;
   my $request;
   for($request = $requests; $request; $request = $request->next()) {
      my $oid = $request->getOID();
      if ($request_info->getMode() == MODE_GET) {
         if ($oid == new NetSNMP::OID($hrMemorySize)) {
             my $value = getMemorySize();
             $request->setValue(ASN_INTEGER, $value);
         }
      } elsif ($request_info->getMode() == MODE_GETNEXT) {
         if ($oid <= new NetSNMP::OID($host)) {
             $request->setOID($hrMemorySize);
             my $value = getMemorySize();
             $request->setValue(ASN_INTEGER, $value);
         }
      }
   }
}

sub getMemorySize{
   my $file = "/proc/meminfo";
   my $total = 0;
   open(FILE,$file) || die("Unable to open file: $!\n");
   while(<FILE>){
      chomp;
      if($_ =~ /^MemTotal/){
         # One Linux (Kernel 2.6.8-2-686), the entry looks like:
         # MemTotal:      1026960 kB
         ($total) = $_ =~ m/^MemTotal:.*?(\d+).*?kB$/;
         last; 
      }
   }
   close(FILE);
   return $total;
}

my $agent = new NetSNMP::agent(
         'Name' => 'snmpd',
         'Ports' => $port);

my $regoid = new NetSNMP::OID($host); #Beginning of Host Resources Tree
print "regoid: $regoid\n";
$regitem = $agent->register("mytest", $regoid, \&myHandler);
if($regitem == 0){
   print "Error registering: $!\n";
   exit -1;
}

my $running = 1;
$SIG{'TERM'} = sub {$running = 0;};
$SIG{'INT'} = sub {$running = 0;};
while($running) {
    $agent->agent_check_and_process(1); # 1 blocks, and 0 does not
}
print "Good-bye!\n";

