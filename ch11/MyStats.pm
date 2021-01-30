#
# File: MyStats.pm
#

package MyStats;
use Class::Struct;
use Exporter;
use SNMP_util;
our (@ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS, $VERSION, $duration, $count,
      $countAndTime, $sla, %watchers);

$VERSION = 1.00; 
@ISA = qw(Exporter);

#
# There are two scenarios we want to track and alert on:
# 1. Some resource has been down a certain number of times
# 2. Service Level Agreements (SLAs). We are concerned with making sure
# services respond and operate within limits set forth in our SLA.
#

struct Count => {
   name   => '$',
   count => '$',
   currentCount => '$',
   message=> '$',
};

struct SLA => {
   name => '$',
   responseTime => '$',
   count => '$',
   currentResponseTime => '$',
   currentCount => '$',
   message=> '$',
};

$count;
$sla;
%watchers;

sub new {
   my $classname  = shift; 
   my $self       = {};
   my %arg  = @_;
   bless($self, $classname);
   return $self;
}

sub removeWatcher{
   my $classname  = shift;
   my ($name) = @_;
   if(exists($watchers{$name})){
      delete($watchers{$name});
   }
}

sub thisExists{
   my $classname  = shift;
   my ($name) = @_;
   return exists($watchers{$name});
}

sub setCountWatcher{
   my $classname = shift;
   my ($name,$c,$message) = @_;
   $count = Count->new();
   $count->name($name);
   $count->count($c);
   $count->message($message);
   $watchers{$name} = $count;
}

sub incrCountWatcher{
   my $classname = shift;
   my ($name) = @_;
   if(exists($watchers{$name})){
      my $count = $watchers{$name}->{Count::currentCount};
      $count++;
      $watchers{$name}->currentCount($count);
   }
}

sub decrCountWatcher{
   my $classname = shift;
   my ($name) = @_;
   if(exists($watchers{$name})){
      my $count = $watchers{$name}->{Count::currentCount};
      if($count > 0){
         $count--;
         $watchers{$name}->currentCount($count);
      }
   }
}

sub setSLA {
   my $classname = shift;
   my ($name,$count,$responseTime,$message) = @_;
   $sla = SLA->new();
   $sla->name($name);
   $sla->count($count);
   $sla->responseTime(sprintf("%.3f",$responseTime));
   $sla->currentCount(0);
   $sla->currentResponseTime(0);
   $sla->message($message);
   $watchers{$name} = $sla;
}

sub updateSLA {
   my $classname = shift;
   my ($name,$responseTime) = @_;
   if(exists($watchers{$name})){
      if($responseTime >= $watchers{$name}->{SLA::responseTime}){
         $watchers{$name}->currentResponseTime($responseTime);
         my $count = $watchers{$name}->{SLA::currentCount};
         $count++;
         $watchers{$name}->currentCount($count);
      }elsif($responseTime < $watchers{$name}->{SLA::responseTime} &&
            $watchers{$name}->{SLA::currentCount} > 0){
         my $count = $watchers{$name}->{SLA::currentCount};
         $count--;
         $watchers{$name}->currentCount($count);
         $watchers{$name}->currentResponseTime($responseTime);
      }
   }
}

sub sendAlert{
   my $classname = shift;
   my $host = "public\@localhost:162";
   my $agent = "localhost";
   my $eid = ".1.3.6.1.4.1.2789";
   my $trapId = 6;
   my $specificId = 1300;
   my $oid = ".1.3.6.1.4.1.2789.1247.1";
   foreach my $key (sort keys %watchers){
      if($watchers{$key}->isa(Count)){
         if($watchers{$key}->{Count::currentCount} >=
               $watchers{$key}->{Count::count}){
            my $message = $watchers{$key}->{Count::message};
            print "Sending Count Trap: $message\n";
            snmptrap($host, $eid, $agent, $trapId,$specificId,$oid,"string",$message);
            $watchers{$key}->currentCount(0);
         }
      }
      if($watchers{$key}->isa(SLA)){
         if($watchers{$key}->{SLA::currentCount} >=
               $watchers{$key}->{SLA::count} &&
               $watchers{$key}->{SLA::currentResponseTime} >
               $watchers{$key}->{SLA::responseTime}){
            my $message = $watchers{$key}->{SLA::message};
            print "Sending SLA Trap: $message\n";
            snmptrap($host, $eid, $agent, $trapId,$specificId,$oid,"string",$message);
            $watchers{$key}->currentCount(0);
         }
      }
   }
}


1;

