#!/usr/bin/perl
#
# File: web-load.pl
#
use LWP::Simple;
use MyStats;

my $URL = "http://www.oreilly.com";
my $count = 3;
my $loadTime = 1;
my $duration = 3;
my $name1 = "URL Watcher1";
my $name2 = "URL Watcher2";
my $message1 = "$URL has been down $count times";
my $message2 = "$URL took greater than $loadTime second(s) to load. The problem persisted for over $duration seconds";

my $stats = MyStats->new();
$stats->setCountWatcher($name1,$count,$message1);
$stats->setSLA($name2,$duration,$loadTime,$message2);

#
# Example taken from O'Reilly and Associates Perl Cookbook 2nd edition
#
my $start = 0;
my $stop = 0;
my $sleep = 1;
while(1){
   $start = time();
   my $content = get($URL);
   if(!defined($content)) {
      # Couldn't get content at all!
      $stats->incrCountWatcher($name1);
   }else{
	  $stats->decrCountWatcher($name1);
      $stop = time();
      my $total = sprintf("%.3f",($stop-$start));
      
      $stats->updateSLA($name2,$total);
   }
   $stats->sendAlert();
   print "Sleeping...\n";
   sleep($sleep);
}

