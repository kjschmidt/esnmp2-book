#!/usr/bin/perl

#
# File: web-badlinks.pl
#
use HTML::LinkExtor;
use LWP::Simple;
use MyStats;

my $URL = "http://www.oreilly.com";
my $count = 3;
my $loadTime = 1;
my $duration = 3;
my $name1 = "URL Watcher1";
my $name2 = "Bad Link Watcher2";
my $message1 = "$URL has been down $count times";
my $message2 = "This URL is BAD: ";

my $stats = MyStats->new();
$stats->setCountWatcher($name1,$count,$message1);

#
# Place links in here that you do not want to check
#
my %exemptLinks = (
    # http://www.oreilly.com/partners/index.php  will not get processed.
   "$URL/partners/index.php"=>1
);

#
# Parts of this Example taken from O'Reilly and Associates Perl Cookbook,
# 2nd edition
#
my $start = 0;
my $stop = 0;
my $sleep = 1;
while(1){
   my $parser = HTML::LinkExtor->new(undef, $URL);
   my $html = get($URL);
   if(!defined($html)){
      # Couldn't get html. Server may be down
      $stats->incrCountWatcher($name1);
   }else{
      $stats->decrCountWatcher($name1);
      $parser->parse($html);
      my @links = $parser->links;
      foreach $linkarray (@links) {
         my @element  = @$linkarray;
         my $elt_type = shift @element;
         while (@element) {
            my ($attr_name,$attr_value) = splice(@element, 0, 2);
            next unless($exemptLinks{$attr_value} != 1);
            if ($attr_value->scheme =~ /\b(ftp|https?|file)\b/) {
               if(!head($attr_value)){
                  if(!$stats->thisExists($attr_value)){
                     my $m = $message2.$attr_value;
                     $stats->setCountWatcher($attr_value,$count,$m);
                  }else{
                     $stats->incrCountWatcher($attr_value);
                  }
               }
            }
         }
      }
   }
   $stats->sendAlert();
   print "Sleeping..\n";
   sleep($sleep);
}

