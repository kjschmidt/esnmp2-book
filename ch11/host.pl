example script which uses this new module:
#!/usr/bin/perl

use SNMP::Info::HostResources;

my $host = new SNMP::Info ( 
                             AutoSpecify => 1,
                             Debug       => 0,
                             DestHost    => '127.0.0.1', 
                             Community   => 'public',
                             Version     => 2
                             );

my $class = $host->class();
print "Using device sub class : $class\n\n";

my $users = $host->hr_users();
my $processes = $host->hr_processes();
my $date = $host->hr_date();

print "(System date: $date) There are $users users running $processes processes\n\n";

my $storage_index = $host->hr_sindex();
my $storage_descr = $host->hr_sdescr();
my $used = $host->hr_sused();

foreach my $index (keys %$storage_index){
   print "$storage_descr->{$index} is using $used->{$index}\n";
}

