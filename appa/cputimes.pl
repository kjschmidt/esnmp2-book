#!/usr/local/bin/perl
# Filename: /usr/local/bin/perl_scripts/cputimes
$|++; # Unbuffer the output!
open(VMSTAT,"/bin/vmstat 2 |") || die "Can't Open VMStat";
while($CLINE=<VMSTAT>)
{    ($null,$r,$b,$w,$swap,$free,$re,$mf,$pi,$po,$fr,$de,$sr,$aa,$dd1,\
$dd2,$f0,$in,$sy,$cs,$us,$sycpu,$id) = split(/\s+/,$CLINE);
    if (($id) && ($id ne "id"))
    {
        $DATE =  date +%m.%d.%y-%H:%M:%S ;
        chomp $DATE;
        print "1 0 $DATE $us \n";
        print "2 0 $DATE $sycpu \n";
        print "3 0 $DATE $id \n";
    }
    sleep 2;
}

