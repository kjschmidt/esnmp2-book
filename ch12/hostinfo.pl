#!/usr/bin/perl

$who = "/usr/bin/who | wc -l";
$ps = "/bin/ps -ef h | wc -l";

chomp($numUsers = int( `$who` ));
chomp($numProcesses = int( `$ps` ));

print "$numUsers\n";
print "$numProcesses\n";
#
# The following code prints the system uptime and the hostname. These two
# items need to be included in every script that you write and should be the
# very last thing that is printed.
#
chomp($uptime =  `/usr/bin/uptime` );
print "$uptime\n";
chomp($hostname =  `/bin/hostname` );
print "$hostname\n";

