public class MainSnmpSet{
  public MainSnmpSet(){
  }

  public static void main(String[] args){
	System.out.println("Doing SNMPv2 set..");
	SnmpSet set = new SnmpSet("127.0.0.1","1.3.6.1.2.1.1.6.0={s}Right here, right now.");
	set.doSet();

	System.out.println("Doing SNMPv3 set..");
	set = new SnmpSet("127.0.0.1",
		"1.3.6.1.2.1.1.6.0={s}Some place else..",
		"kschmidt","MD5","mysecretpass","DES","mypassphrase");
	set.doSet();
  }
}

