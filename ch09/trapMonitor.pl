#!/usr/local/bin/perl
use SNMP_Session "0.60";
use BER;
use Socket;
$session = SNMPv1_Session->open_trap_session ();
while (($trap, $sender, $sender_port) = $session->receive_trap ())
{    chomp ($DATE= `/bin/date \'+%a %b %e %T\'` );
    print STDERR "$DATE - " . inet_ntoa($sender) . " - port: $sender_port\n";
    print_trap ($session, $trap);
}
1;
sub print_trap ($$) {
    ($this, $trap) = @_;
    ($community, $ent, $agent, $gen, $spec, $dt, @bindings) = \
     $this->decode_trap_request ($trap);
    print "   Community:\t".$community."\n";
    print "   Enterprise:\t".BER::pretty_oid ($ent)."\n";
    print "   Agent addr:\t".inet_ntoa ($agent)."\n";
    print "   Generic ID:\t$gen\n";
    print "   Specific ID:\t$spec\n";
    print "   Uptime:\t".BER::pretty_uptime_value ($dt)."\n";
    $prefix = "   bindings:\t";
    foreach $encoded_pair (@bindings) {
        ($oid, $value) = decode_by_template ($encoded_pair, "%{%O%@");
        #next unless defined $oid;
        print $prefix.BER::pretty_oid ($oid)." => ".pretty_print ($value)."\n";
        $prefix = "  ";
    }
}

