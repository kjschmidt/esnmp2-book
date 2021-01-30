#!/usr/bin/perl

#
# File: smtp.pl
#
use Net::SMTP;
use MyStats;

my $sleep = 1;
my $server = "smtp.oreilly.com";
my $heloSever = "smtp.oreilly.com";
my $timeout = 30;
my $debug = 1;
my $count = 3;
my $loadTime = 1;
my $duration = 3;
my $mailbox = "test1\@oreilly.com";
my $from = "test1-admin\@oreilly.com";
my $data = "This is a test email.\n";
my $name1 = "Mail Server Watcher1";
my $name2 = "Mail Server Watcher2";
my $message1 = "$server has been down $count times";
my $message2 = "Sending email to $mailbox took greater than $loadTime second(s). The problem persisted for over $duration seconds";

$stats = MyStats->new();
$stats->setCountWatcher($name1,$count,$message1);
$stats->setSLA($name2,$duration,$loadTime,$message2);

my $start = 0;
my $stop = 0;
while(1){
   $start = time();
   my $smtp = Net::SMTP->new(
      $server,
      Hello=>$heloServer,
      Timeout => $timeout,
      Debug => $debug
      );
   if(!$smtp){
      $stats->incrCountWatcher($name1);
   }else{
      $stats->decrCountWatcher($name1);
      $smtp->mail($mailbox);
      $smtp->to($from);
      $smtp->data();
      $smtp->datasend($data);
      $smtp->dataend();
      $smtp->quit;
      $end = time();
      my $total = sprintf("%.3f",($stop-$start));
      $stats->updateSLA($name2);
   }
   $stats->sendAlert();
   print "Sleeping...\n";
   sleep($sleep);
}

