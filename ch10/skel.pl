#!/usr/local/bin/perl
if ($ARGV[0] == 1) {
   # OID queried is 1.3.6.1.4.1.546.14.1.0
   if ($ARGV[1] eq "SET") {
          # use $ARGV[2] to set the value of something and return the set 
          # followed by a newline character, to the agent
   } elsif (($ARGV[1] eq "GET") || ($ARGV[1] eq "GETNEXT")) {
          # get the information to which this OID pertains, then return it
          # followed by a newline character, to the agent
   }
} else {
   return 0;
   # return 0, since I don't know what to do with this OID
}

