#!/usr/bin/perl

use SNMP;

use Getopt::Long;
GetOptions("mac=s"  => \$gMac,
           "index=s" => \$gIndex,
           "action=s" => \$gAction,
           );

($gMac,$gAction,$gIndex) = verifyInput($gMac,$gAction,$gIndex);

&SNMP::initMib();
&SNMP::loadModules(qw/BRIDGE-MIB/);

my $host = "192.168.0.148";
my $roComm = "public";
my $rwComm = "private";

$roSession = new SNMP::Session(DestHost => $host, Community => $roComm,
                                UseSprintValue => 1, Version=>2);
die "session creation error: $SNMP::Session::ErrorStr" unless
   (defined $roSession);
   
$rwSession = new SNMP::Session(DestHost => $host, Community => $rwComm,
                                UseSprintValue => 1, Version=>2);
die "session creation error: $SNMP::Session::ErrorStr" unless
   (defined $rwSession);

findMac();

sub findMac {
   my($discover) = @_;
   $vars = new SNMP::VarList(['dot1dTpFdbAddress'], ['dot1dTpFdbPort']);
   # get first row
   my ($mac, $port) = $roSession->getnext($vars);
   die $roSession->{ErrorStr} if ($roSession->{ErrorStr});
   while (!$roSession->{ErrorStr} and $$vars[0]->tag eq "dot1dTpFdbAddress" 
         || $$vars[0]->tag eq "dot1dBasePortIfIndex"){
      my @tmac = $mac =~ m/(\w{1,2}) (\w{1,2}) (\w{1,2}) (\w{1,2}) (\w{1,2}) (\w{1,2})/g;
      $mac = sanitizeMac(sprintf("%s:%s:%s:%s:%s:%s",@tmac));
      if($gMac eq $mac){
         # We found it
         my $ifnum = $roSession->get("dot1dBasePortIfIndex\.$port");
         if($ifnum eq $gIndex){
            doAction($gAction,$ifnum);
         }else{
            print "$mac has moved to ifIndex $ifnum\n";
         }
         last;
      }
      # keep going
      ($mac, $port) = $roSession->getnext($vars);
   }
}

sub doAction{
   my ($action,$ifnum) = @_;
   my $ifname = $roSession->get("ifDescr\.$ifnum");
   if($action eq "up"){
      print "Turning $ifname $action (ifNum is $ifnum)..\n";
      $rwSession->set([["ifAdminStatus", $ifnum, 1, "INTEGER"]]);
   }elsif($action eq "down"){
      print "Turning $ifname $action (ifNum is $ifnum)...\n";
      $rwSession->set([["ifAdminStatus", $ifnum, 2, "INTEGER"]]); 
   }
   if($rwSession->{ErrorStr}){
      print "An error occurred during processing: $rwSession->{ErrorStr}\n";
   }
}

sub sanitizeMac{
   my($mac) = @_;
   my @tmac = split(/:/,$mac);
   foreach my $byte (0..$#tmac){
      $tmac[$byte] =~ s/^0//g;
      $tmac[$byte] = lc($tmac[$byte]);
   }
   $mac = sprintf("%s:%s:%s:%s:%s:%s",@tmac);
   return $mac;
}


sub verifyInput{
   my($mac,$action,$index) = @_;
   if(($mac eq "" && $action eq "" && $index eq "")) {
      usage();
      exit;
   }
   if($action eq ""){
      usage();
      exit;
   }
   $mac = sanitizeMac($mac);
   $action = lc($action);
   if($action ne "up" && $action ne "down"){
      usage();
      exit;
   }
   return ($mac,$action,$index);
}

sub usage{
   print "Usage:\t$0 --mac=0:f:0:d:55:a --index=10 --action=up\n";
   print "\tSpecify a MAC adddress and the index in the interfaces MIB tree where this port lives on the switch. Action can be EITHER \"up\" OR \"down\"\n";
}

