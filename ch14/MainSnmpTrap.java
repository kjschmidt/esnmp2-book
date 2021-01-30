public class MainSnmpTrap{
	  public MainSnmpTrap(){
	  }

	  public static void main(String[] args){
		System.out.println("Doing SNMPv2 trap..");
		SnmpTrap trap = new SnmpTrap("127.0.0.1",
			"1.3.6.1.4.1.2789.2005.1={s}WWW Server Has Been Restarted",1);
		trap.doTrap();

		System.out.println("Doing SNMPv3 trap..");
		trap = new SnmpTrap("127.0.0.1",
			"1.3.6.1.4.1.2789.2005.1={s}WWW Server Has Been Restarted",
			1,"kschmidt","MD5","mysecretpass","DES","mypassphrase");
		trap.doTrap();

		System.out.println("Doing SNMPv2 inform..");
		trap = new SnmpTrap("127.0.0.1",
			"1.3.6.1.4.1.2789.2005.1={s}WWW Server Has Been Restarted",2);
		trap.doTrap();

		System.out.println("Doing SNMPv3 inform..");
		trap = new SnmpTrap("127.0.0.1",
			"1.3.6.1.4.1.2789.2005.1={s}WWW Server Has Been Restarted",
			2,"kschmidt","MD5","mysecretpass","DES","mypassphrase");
		trap.doTrap();
	  }
}

