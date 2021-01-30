#!/usr/bin/perl

#
# File: pop3.pl
#
use Net::POP3;
use MyStats;

my $sleep = 1;
my $server = "pop3.oreilly.com";
my $username = "kschmidt";
my $password = "pword";
my $timeout = 30;
my $count = 3;
my $loadTime = 1;
my $duration = 3;
my $name1 = "POP3 Server Watcher1";
my $name2 = "POP3 Server Watcher2";
my $message1 = "$server has been down $count times";
my $message2 = "Popping email from $server for account $username took greater than $loadTime second(s). The problem persisted for over $duration seconds";

$stats = MyStats->new();
$stats->setCountWatcher($name1,$count,$message1);
$stats->setSLA($name2,$duration,$loadTime,$message2);

my $start = 0;
my $stop = 0;
while(1){
   $start = time();
   my $pop = Net::POP3->new($server, Timeout => $timeout);
   if(!$pop){
      $stats->incrCountWatcher($name1);
   }else{
      $stats->decrCountWatcher($name1);
      if ($pop->login($username, $password) > 0) {
         my $msgnums = $pop->list; # hashref of msgnum => size
         foreach my $msgnum (keys %$msgnums) {
            # At this point we get the message and delete it. If you want to
            # measure getting and deleting independent of each other, you 
            # should probably start a new timer, get the messages, stop the
            # timer, start a new timer, delete the messages and stop the
            # timer. You will also want to create two new SLA trackers.
            my $msg = $pop->get($msgnum);
            $pop->delete($msgnum);
         }
      }else{
         # Login failure. You will want to track this.
      }
      $pop->quit;
      $end = time();
      my $total = sprintf("%.3f",($stop-$start));
      $stats->updateSLA($name2);
   }
   $stats->sendAlert();
   print "Sleeping..\n";
   sleep($sleep);
}

